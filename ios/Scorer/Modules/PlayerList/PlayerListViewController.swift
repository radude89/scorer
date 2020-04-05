//
//  PlayerListViewController.swift
//  Scorer
//
//  Created by Radu Dan on 02/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit
import ScorerFoundation

// MARK: - PlayerListTogglable
protocol PlayerListTogglable: AnyObject {
    func toggleViewState()
}

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionButton: UIButton!
    private var barButtonItem: UIBarButtonItem!
    
    private var viewState: PlayerListViewState = .list
    private let playersService = StandardNetworkService(resourcePath: "/api/players")
    private var players: [Player] = []
    private var selectedPlayersDictionary: [Int: Player] = [:]
    private var selectedPlayerForViewingDetails: Player?
    
    private var teamPlayersDictionary: [TeamSection: [Player]] {
        var playersDictionary: [TeamSection: [Player]] = [:]
        playersDictionary[.bench] = Array(selectedPlayersDictionary.values)

        return playersDictionary
    }

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupBarButtonItem()
        loadPlayers()
    }
    
    private func setupTitle() {
        if viewState == .selection {
            let selectedPlayersCount = selectedPlayersDictionary.values.count
            title = selectedPlayersCount > 0 ? "\(selectedPlayersCount) selected" : "Players"
        } else {
            title = "Players"
        }
    }
    
    private func setupBarButtonItem() {
        barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
        navigationItem.rightBarButtonItem = barButtonItem
        barButtonItem.isEnabled = false
    }

    // MARK: - Load data
    func loadPlayers() {
        playersService.get { [weak self] (result: Result<[Player], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.handleError(title: "Error", message: String(describing: error))
                    
                case .success(let players):
                    self?.players = players
                    self?.handleLoadPlayersSuccessfulResponse()
                }
            }
        }
    }
    
    private func handleError(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    private func handleLoadPlayersSuccessfulResponse() {
        barButtonItem.isEnabled = !players.isEmpty
        playerTableView.reloadData()
    }
    
    // MARK: - Selectors
    @IBAction private func confirmPlayers(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifier.confirmPlayers.rawValue, sender: nil)
    }
    
    @IBAction private func exportGathers(_ sender: Any) {
        ExportService().exportGathers { [weak self] gathersExported in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if gathersExported {
                    AlertHelper.present(in: self, title: "Gathers exported", message: "Go check out your website. We have refreshed the list of gathers.")
                } else {
                    self.handleError(title: "Error", message: "Something went wrong.")
                }
            }
        }
    }
    
    @objc private func selectPlayers() {
        toggleViewState()
    }
    
    private var actionButtonIsEnabled: Bool {
        if viewState == .selection {
            return playersCanPlay
        }
        
        return false
    }
    
    private let minimumPlayersToPlay = 2
    private var playersCanPlay: Bool { selectedPlayersDictionary.values.count >= minimumPlayersToPlay }
    
    // MARK: - Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifier.playerDetails.rawValue:
            let playerDetailsViewController = segue.destination as? PlayerDetailsViewController
            playerDetailsViewController?.delegate = self
            playerDetailsViewController?.player = selectedPlayerForViewingDetails
            
        case SegueIdentifier.confirmPlayers.rawValue:
            (segue.destination as? ConfirmPlayersViewController)?.playersDictionary = teamPlayersDictionary

        default:
            break
        }
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { players.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }
        
        if viewState == .list {
            selectedPlayersDictionary[indexPath.row] = nil
            cell.setupDefaultView()
        } else {
            cell.setupSelectionView()
        }
        
        let player = players[indexPath.row]

        cell.nameLabel.text = player.name
        
        if let position = player.preferredPosition {
            cell.positionLabel.text = "Position: \(position.rawValue)"
        } else {
            cell.positionLabel.text = "Position: -"
        }
        
        if let skill = player.skill {
            cell.skillLabel.text = "Skill: \(skill.rawValue)"
        } else {
            cell.skillLabel.text = "Skill: -"
        }
        
        if let lastUpdated = player.lastUpdated {
            cell.lastUpdatedLabel.text = "Last updated: \(lastUpdated.formattedString)"
        } else {
            cell.lastUpdatedLabel.text = "Last updated: -"
        }

        cell.playerIsSelected = selectedPlayersDictionary[indexPath.row] != nil

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !players.isEmpty else { return }

        if viewState == .list {
            navigateToPlayerDetails(withPlayer: players[indexPath.row])
        } else {
            toggleCellSelection(at: indexPath)
            updateViewForPlayerSelection()
        }
    }

    private func navigateToPlayerDetails(withPlayer player: Player) {
        selectedPlayerForViewingDetails = player
        performSegue(withIdentifier: SegueIdentifier.playerDetails.rawValue, sender: nil)
    }

    private func toggleCellSelection(at indexPath: IndexPath) {
        guard let cell = playerTableView.cellForRow(at: indexPath) as? PlayerTableViewCell else { return }

        cell.playerIsSelected.toggle()
        updateSelectedPlayers(isSelected: cell.playerIsSelected, at: indexPath)
    }
    
    private func updateSelectedPlayers(isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
        } else {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }

    private func updateViewForPlayerSelection() {
        setupTitle()
        bottomActionButton.isEnabled = playersCanPlay
    }
}

// MARK: - PlayerDetailsViewControllerDelegate
extension PlayerListViewController: PlayerDetailsViewControllerDelegate {
    func didEdit(player: Player) {
        loadPlayers()
        playerTableView.reloadData()
    }
}

// MARK: - PlayerListTogglable
extension PlayerListViewController: PlayerListTogglable {
    func toggleViewState() {
        viewState.toggle()
        setupTitle()
        barButtonItem.title = viewState == .selection ? "Cancel" : "Select"
        bottomActionButton.isEnabled = actionButtonIsEnabled
        playerTableView.reloadData()
    }
}
