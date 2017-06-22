import UIKit
import FirebaseDatabase


class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var taskList = [String: String]()
    var taskRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.taskRef = Database.database().reference().child("tasks")
        
        self.taskRef.observe(DataEventType.childAdded, with: {(data) in
            print("childAdded \(data)")
            guard let dictionary = data.value as? NSDictionary else{
                return
            }
            self.taskList[data.key] = dictionary["task"] as? String
            self.tableView.reloadData()
        })
        
        self.taskRef.observe(DataEventType.childChanged, with: {(data) in
            print("childchange\(data)")
            guard let dictionary = data.value as? NSDictionary else{
                return
            }
            self.taskList[data.key] = dictionary["task"] as? String
            self.tableView.reloadData()
            
        })
        
        self.taskRef.observe(DataEventType.childRemoved, with: {(data) in
            print("childRemoved \(data)")
            
            self.taskList.removeValue(forKey: data.key)
            self.tableView.reloadData()
        })
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Array(self.taskList.values)[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Task", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {(textfield) in
            textfield.text = Array(self.taskList.values)[indexPath.row]
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler:{
            (action) -> Void in
            let text = alert.textFields![0].text!
            let ref = self.taskRef!
            let autoID = Array(self.taskList.keys)[indexPath.row]
            ref.child(autoID).updateChildValues(["task": text])
            
        })
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ref = self.taskRef!
            let autoID = Array(self.taskList.keys)[indexPath.row]
            ref.child(autoID).removeValue()
            
        }
    }
    @IBAction func AddTaskPressed(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Task", message: "Add Task", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler:{
            (action) -> Void in
            let text = alert.textFields![0].text!
            let ref = self.taskRef
            ref?.childByAutoId().setValue(["task":text])
        })
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,animated: true, completion: nil)
        
    }
}
