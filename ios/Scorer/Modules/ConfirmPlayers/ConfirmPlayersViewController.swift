//
//  ConfirmPlayersViewController.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit
import ScorerFoundation

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!
    
    var playersDictionary: [TeamSection: [Player]] = [:]
    
    private let dispatchGroup = DispatchGroup()
    private var gatherUUID: UUID?
    private var addPlayerService = AddPlayerToGatherService()
    private let gatherService = StandardNetworkService(resourcePath: "/api/gathers")

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Confirm players"
        playerTableView.isEditing = true
        configureStartGatherButton()
    }
    
    private func configureStartGatherButton() {
        startGatherButton.isEnabled = startGatherButtonIsEnabled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.gather.rawValue, let gatherUUID = gatherUUID {
            let gatherViewController = segue.destination as? GatherViewController
            gatherViewController?.gather = Gather(id: gatherUUID)
            gatherViewController?.playerTeams = playerTeamArray
        }
    }
    
    // MARK: - Start gather methods
    private var startGatherButtonIsEnabled: Bool {
        if playersDictionary[.teamA]?.isEmpty == false &&
            playersDictionary[.teamB]?.isEmpty == false {
            return true
        }
        
        return false
    }
    
    @IBAction private func startGather(_ sender: Any) {
//        initiateStartGather()
        startGatherBFF()
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { TeamSection.allCases.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TeamSection(rawValue: section)?.teamDescription
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = TeamSection(rawValue: section), let players = playersDictionary[team] else { return 0 }
        
        return players.count
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerChooseTableViewCellId") else {
            return UITableViewCell()
        }
        
        if let team = TeamSection(rawValue: indexPath.section), let players = playersDictionary[team] {
            let player = players[indexPath.row]
            cell.textLabel?.text = player.name
            cell.detailTextLabel?.text = player.preferredPosition?.acronym
        }

        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRowAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)
        configureStartGatherButton()
    }
    
    private func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceTeam = TeamSection(rawValue: sourceIndexPath.section),
            let sourcePlayer = playersDictionary[sourceTeam]?[sourceIndexPath.row],
            let destinationTeam = TeamSection(rawValue: destinationIndexPath.section) else {
                fatalError("Unable to move players")
        }
        
        playersDictionary[sourceTeam]?.remove(at: sourceIndexPath.row)
        
        if playersDictionary[destinationTeam]?.isEmpty == false {
            playersDictionary[destinationTeam]?.insert(sourcePlayer, at: destinationIndexPath.row)
        } else {
            playersDictionary[destinationTeam] = [sourcePlayer]
        }
    }
}

// MARK: - Service
extension ConfirmPlayersViewController {
    private func handleError(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    private func handleSuccessfulStartGather() {
        performSegue(withIdentifier: SegueIdentifier.gather.rawValue, sender: nil)
    }
    
    private func startGatherBFF() {
        StartGatherService().startGather(with: playerTeamArray) { [weak self] gatherUUID in
            DispatchQueue.main.async {
                if let gatherUUID = gatherUUID {
                    self?.gatherUUID = gatherUUID
                    self?.handleSuccessfulStartGather()
                } else {
                    self?.handleError(title: "Error", message: "Something happened, please try again.")
                }
            }
        }
    }
    
    private func initiateStartGather() {
        startGather { [weak self] result in
            DispatchQueue.main.async {
                if !result {
                    self?.handleError(title: "Error", message: "Unable to create gather.")
                } else {
                    self?.handleSuccessfulStartGather()
                }
            }
        }
    }
    
    private func startGather(completion: @escaping (Bool) -> ()) {
        createGather { [weak self] uuid in
            guard let gatherUUID = uuid else {
                completion(false)
                return
            }
            
            self?.gatherUUID = gatherUUID
            self?.addPlayersToGather(havingUUID: gatherUUID, completion: completion)
        }
    }
    
    private func createGather(completion: @escaping (UUID?) -> Void) {
        gatherService.create(Gather()) { result in
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                completion(gatherUUID)
            } else {
                completion(nil)
            }
        }
    }
    
    private func addPlayersToGather(havingUUID gatherUUID: UUID, completion: @escaping (Bool) -> ()) {
        var serviceFailed = false
        
        playerTeamArray.forEach { playerTeam in
            dispatchGroup.enter()
            
            self.addPlayer(playerTeam.player, toGatherHavingUUID: gatherUUID, team: playerTeam.team) { [weak self] playerWasAdded in
                if !playerWasAdded {
                    serviceFailed = true
                }
                
                self?.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(serviceFailed)
        }
    }
    
    private var playerTeamArray: [PlayerTeam] {
        var players: [PlayerTeam] = []
        players += self.playersDictionary
            .filter { $0.key == .teamA }
            .flatMap { $0.value }
            .map { PlayerTeam(team: .teamA, player: $0) }
        
        players += self.playersDictionary
            .filter { $0.key == .teamB }
            .flatMap { $0.value }
            .map { PlayerTeam(team: .teamB, player: $0) }
        
        return players
    }
    
    private func addPlayer(_ player: Player,
                           toGatherHavingUUID gatherUUID: UUID,
                           team: TeamSection,
                           completion: @escaping (Bool) -> Void) {
        addPlayerService.addPlayer(
            havingServerId: player.id!,
            toGatherWithId: gatherUUID,
            team: PlayerGatherTeam(team: team.teamDescription)) { result in
                if case let .success(resultValue) = result {
                    completion(resultValue)
                } else {
                    completion(false)
                }
        }
    }
}
