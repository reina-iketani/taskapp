//
//  ViewController.swift
//  taskapp
//
//  Created by Reina Iketani on 2023/06/05.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    let realm = try! Realm()
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    var filteredTaskArray: Results<Task>? = nil
    var category: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.fillerRowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTaskArray?.count ?? taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

            let task: Task
            if let filteredTasks = filteredTaskArray {
                
                task = filteredTasks[indexPath.row]
                
            } else {
                task = taskArray[indexPath.row]
            }

            cell.textLabel?.text = task.title
            
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString: String = formatter.string(from: task.date)
                cell.detailTextLabel?.text = dateString
            


            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let task = self.taskArray[indexPath.row]
            
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id.stringValue)])
            
            try! realm.write{
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
                
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let task: Task
                if let filteredTasks = filteredTaskArray, !filteredTasks.isEmpty {
                    // 検索結果がある場合、該当のタスクを取得
                    task = filteredTasks[indexPath.row]
                } else {
                    // 検索結果がない場合、全データの中から該当のタスクを取得
                    task = taskArray[indexPath.row]
                }
                inputViewController.task = task
            }
        } else {
            inputViewController.task = Task()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    // 入力された値がnilでなければif文のブロック内の処理を実行
        if let category = searchBar.text {
            self.category = category
            filteredTaskArray = realm.objects(Task.self).filter("category == %@", category).sorted(byKeyPath: "date", ascending: true)
            
        } else{
            filteredTaskArray = nil
        }
            
            tableView.reloadData()
        // キーボードを閉じる
            view.endEditing(true)
    }
    
    
    @IBAction func refreshSearch(_ sender: Any) {
        searchBar.text = nil
        filteredTaskArray = nil
        category = nil
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    
    
    
}
