//
//  PlayerDetailsViewController.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit
import ScorerFoundation

// MARK: - PlayerDetailViewControllerDelegate
protocol PlayerDetailsViewControllerDelegate: AnyObject {
    func didEdit(player: Player)
}

// MARK: - PlayerDetailsViewController
final class PlayerDetailsViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerDetailTableView: UITableView!
    
    var player: Player!
    weak var delegate: PlayerDetailsViewControllerDelegate?
    
    private lazy var sections = PlayerSectionFactory.makeSections(fromPlayer: player)
    private var selectedPlayerRow: PlayerRow?
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        reloadData()
    }
    
    private func setupTitle() {
        title = player.name
    }
    
    private func reloadData() {
        playerDetailTableView.reloadData()
    }
    
    // MARK: - Edit methods
    var destinationViewType: PlayerEditViewType {
        if shouldEditSelectionTypeField {
            return .selection
        }
        
        return .text
    }
    
    private var shouldEditSelectionTypeField: Bool {
        guard let selectedPlayerRow = selectedPlayerRow else { return false }
        
        return  selectedPlayerRow.editableField == .position || selectedPlayerRow.editableField == .skill
    }
    
    private var playerEditModel: PlayerEditModel? {
        guard let selectedPlayerRow = selectedPlayerRow else { return nil }
        
        return PlayerEditModel(player: player, playerRow: selectedPlayerRow)
    }

    private var playerItemsEditModel: PlayerItemsEditModel? {
        guard shouldEditSelectionTypeField else { return nil }
        
        return PlayerItemsEditModel(items: editableItems, selectedItemIndex: indexOfSelectedItem ?? -1)
    }
    
    private var editableItems: [String] {
        guard let selectedPlayerRow = selectedPlayerRow else { return [] }
        
        if selectedPlayerRow.editableField == .position {
            return PlayerPosition.allCases.map { $0.rawValue }
        }
        
        return PlayerSkill.allCases.map { $0.rawValue }
    }
    
    private var indexOfSelectedItem: Int? {
        guard let selectedPlayerRow = selectedPlayerRow else { return nil }
        
        return editableItems.firstIndex(of: selectedPlayerRow.value.lowercased())
    }
    
    // MARK: - Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifier.editPlayer.rawValue,
            let destinationViewController = segue.destination as? PlayerEditViewController else {
                return
        }
        
        destinationViewController.viewType = destinationViewType
        destinationViewController.playerEditModel = playerEditModel
        destinationViewController.playerItemsEditModel = playerItemsEditModel
        destinationViewController.delegate = self
    }
    
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailsTableViewCell") as? PlayerDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        let row = sections[indexPath.section].rows[indexPath.row]

        cell.leftLabel.text = row.title
        cell.rightLabel.text = row.value

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title.uppercased()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayerRow = sections[indexPath.section].rows[indexPath.row]
        performSegue(withIdentifier: SegueIdentifier.editPlayer.rawValue, sender: nil)
    }
}

// MARK: - PlayerEditViewControllerDelegate
extension PlayerDetailsViewController: PlayerEditViewControllerDelegate {
    func didFinishEditing(player: Player) {
        self.player = player
        setupTitle()
        sections = PlayerSectionFactory.makeSections(fromPlayer: player)
        reloadData()
        delegate?.didEdit(player: player)
    }
}
