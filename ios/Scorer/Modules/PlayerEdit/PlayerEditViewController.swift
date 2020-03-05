//
//  PlayerEditViewController.swift
//  Scorer
//
//  Created by Radu Dan on 03/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit
import ScorerFoundation

// MARK: - PlayerEditViewType
enum PlayerEditViewType {
    case text, selection
}

// MARK: - PlayerEditViewControllerDelegate
protocol PlayerEditViewControllerDelegate: AnyObject {
    func didFinishEditing(player: Player)
}

// MARK: - PlayerEditViewController
final class PlayerEditViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var playerEditTextField: UITextField!
    @IBOutlet weak var playerTableView: UITableView!

    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    
    var viewType: PlayerEditViewType = .text
    var playerEditModel: PlayerEditModel!
    var playerItemsEditModel: PlayerItemsEditModel!
    weak var delegate: PlayerEditViewControllerDelegate?
    
    private var playerService = StandardNetworkService(resourcePath: "/api/players")
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupNavigationItems()
        setupPlayerEditTextField()
        setupTableView()
    }
    
    private func setupTitle() {
        title = playerEditModel.playerRow.title
    }
    
    private func setupNavigationItems() {
        doneButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneButton
    }
    
    private func setupPlayerEditTextField() {
        playerEditTextField.placeholder = playerEditModel.playerRow.value
        playerEditTextField.text = playerEditModel.playerRow.value
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        playerEditTextField.isHidden = viewType == .selection
    }
    
    private func setupTableView() {
        playerTableView.isHidden = viewType == .text
    }
    
    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = doneButtonIsEnabled(newValue: playerEditTextField.text)
    }

    @objc private func doneAction(sender: UIBarButtonItem) {
        updatePlayerBasedOnViewType(inputFieldValue: playerEditTextField.text)
    }
    
    private func doneButtonIsEnabled(newValue: String?) -> Bool {
        if let newValue = newValue, playerEditModel.playerRow.value.lowercased() != newValue.lowercased() {
            return true
        }
        
        return false
    }
    
    // MARK: - Update
    func updatePlayerBasedOnViewType(inputFieldValue: String?) {
        guard shouldUpdatePlayer(inputFieldValue: inputFieldValue) else { return }
                
        let fieldValue = viewType == .selection ? selectedItemValue : inputFieldValue
        
        updatePlayer(newFieldValue: fieldValue) { [weak self] updated in
            DispatchQueue.main.async {
                self?.handleUpdatedPlayerResult(updated)
            }
        }
    }
    
    private func shouldUpdatePlayer(inputFieldValue: String?) -> Bool {
        if viewType == .selection {
            return newValueIsDifferentFromOldValue(newFieldValue: selectedItemValue)
        }
        
        return newValueIsDifferentFromOldValue(newFieldValue: inputFieldValue)
    }
    
    private func newValueIsDifferentFromOldValue(newFieldValue: String?) -> Bool {
        guard let newFieldValue = newFieldValue else { return false }
        
        return playerEditModel.playerRow.value.lowercased() != newFieldValue.lowercased()
    }

    private func updatePlayer(newFieldValue: String?, completion: @escaping (Bool) -> ()) {
        guard let newFieldValue = newFieldValue else {
            completion(false)
            return
        }
        
        playerEditModel.player.update(usingField: playerEditModel.playerRow.editableField, value: newFieldValue)
        requestUpdatePlayer(completion: completion)
    }
    
    private var selectedItemValue: String? {
        guard let playerItemsEditModel = playerItemsEditModel else { return nil}
        
        return playerItemsEditModel.items[playerItemsEditModel.selectedItemIndex]
    }
    
    private func requestUpdatePlayer(completion: @escaping (Bool) -> ()) {
        playerEditModel.player.lastUpdated = nil
        let player = playerEditModel.player
        playerService.update(player, resourceID: ResourceID.integer(player.id!)) { [weak self] result in
            if case .success(let updated) = result {
                self?.playerEditModel.player = player
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
    private func handleUpdatedPlayerResult(_ playerWasUpdated: Bool) {
        if playerWasUpdated {
            handleSuccessfulPlayerUpdate()
        } else {
            handleError(title: "Error update", message: "Unable to update player. Please try again.")
        }
    }

    private func handleError(title: String, message: String) {
        AlertHelper.present(in: self, title: "Error update", message: "Unable to update player. Please try again.")
    }
    
    private func handleSuccessfulPlayerUpdate() {
        delegate?.didFinishEditing(player: playerEditModel.player)
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerItemsEditModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }

        cell.textLabel?.text = playerItemsEditModel?.items[indexPath.row].capitalized
        cell.accessoryType = playerItemsEditModel?.selectedItemIndex == indexPath.row ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItemIndex = playerItemsEditModel?.selectedItemIndex {
            clearAccessoryType(forSelectedIndex: selectedItemIndex)
        }

        playerItemsEditModel?.selectedItemIndex = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        doneButton.isEnabled = doneButtonIsEnabled(selectedIndexPath: indexPath)
    }
    
    private func doneButtonIsEnabled(selectedIndexPath: IndexPath) -> Bool {
        if let newValue = playerItemsEditModel?.items[selectedIndexPath.row],
            playerEditModel.playerRow.value.lowercased() != newValue.lowercased() {
            return true
        }
        
        return false
    }

    private func clearAccessoryType(forSelectedIndex selectedItemIndex: Int) {
        let indexPath = IndexPath(row: selectedItemIndex, section: 0)
        playerTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
