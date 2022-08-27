//
//  TaskListViewController.swift
//  TaskList_v2
//
//  Created by Алексей on 25.08.2022.
//

import UIKit
import RealmSwift

class TaskListViewController: UITableViewController {
    
    var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        createTempDate()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
        
        title = "You have \(taskLists.count) tasks"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data sourse
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.name
        content.secondaryText = "\(taskList.tasks.count)"
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
                isDone(true)
            }
        }
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        doneAction.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        editAction.backgroundColor = .orange
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction, doneAction])
    }
}

    // MARK: - Navigation
extension TaskListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
    
    @IBAction func sortingList(_ sender: UISegmentedControl) {
    }
    
    @objc private func addButtonPressed() {
            showAlert()
    }
    
    private func createTempDate() {
        DataManager.shared.createTempData { [unowned self] in
            tableView.reloadData()
        }
    }
    
    private func save(taskList: String) {
        StorageManager.shared.save(taskList) { taskList in
            let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}

    // MARK: - Alert
extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskLists != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
        alert.action(with: taskList) { [weak self] newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList, newValue: newValue)
                completion()
            } else {
                self?.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
}
