//
//  DataManager.swift
//  TaskList_v2
//
//  Created by Алексей on 25.08.2022.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            let shoppingList = TaskList()
            shoppingList.name = "Shopping List"
            
            let milk = Task()
            milk.name = "Milk"
            milk.note = "3L"
            
//            shoppingList.tasks.append(milk) добавление
            
            let bread = Task(value: ["Bread", "", Date(), true])
            let apples = Task(value: ["name": "Apples", "note": "2Kg"])
            
            shoppingList.tasks.insert(contentsOf: [milk, bread, apples], at: 0) // at индекс с которого коллекция вставляется
            
            DispatchQueue.main.async {
                StorageManager.shared.save([shoppingList])
                UserDefaults.standard.set(true, forKey: "done")
                completion()
            }
        }
    }
    
}
