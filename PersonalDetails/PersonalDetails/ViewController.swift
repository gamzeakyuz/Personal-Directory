//
//  ViewController.swift
//  PersonalDetails
//
//  Created by Gamze Akyüz on 27.08.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var person = [Person]()
    let dateFormatter = DateFormatter()

    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var openButton: UIBarButtonItem!
    
    var panelView: UIView!
    var isPanelOpen = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panelView = UIView(frame: CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 150))
        panelView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        view.addSubview(panelView)
        
        
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: panelView.frame.width - 40, height: 30))
        label.text = "İnfo"
        label.textAlignment = .center
        label.textColor = UIColor.blue
        label.font = UIFont(name: label.font.fontName, size: 20)
        panelView.addSubview(label)
        
        let label1 = UILabel(frame: CGRect(x: 20, y: 20, width: panelView.frame.width - 40, height: 90))
        label1.text = "Swipe to update data"
        label1.textAlignment = .center
        label1.textColor = UIColor.black
        label1.font = UIFont(name: label1.font.fontName, size: 15)
        panelView.addSubview(label1)
        
        let label2 = UILabel(frame: CGRect(x: 20, y: 20, width: panelView.frame.width - 40, height: 130))
        label2.text = "Swipe to sort A-Z"
        label2.textAlignment = .center
        label2.textColor = UIColor.black
        label2.font = UIFont(name: label2.font.fontName, size: 15)
        panelView.addSubview(label2)
        
        openButton.target = self
        openButton.action = #selector(openPanelButtonTapped)
        
        navigationController?.navigationBar.tintColor = UIColor.black
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
    
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    @objc func openPanelButtonTapped() {
        if isPanelOpen {
            hidePanel()
        } else {
            showPanel()
        }
    }

    func showPanel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.panelView.frame.origin.y = self.view.frame.height - self.panelView.frame.height
        }) { _ in
            self.isPanelOpen = true
        }
    }

    func hidePanel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.panelView.frame.origin.y = self.view.frame.height
        }) { _ in
            self.isPanelOpen = false
        }
    }
    
    func fetchData() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                person = try context.fetch(fetchRequest)
                for persons in person {
                    context.refresh(persons, mergeChanges: true)
                }
            } catch {
                print("Veri çekilirken bir hata oluştu: \(error)")
            }
    }

    @objc func refreshData() {
        
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
        
        fetchData()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        do {
            try context.save()
        } catch {
            print("Veri güncellenirken bir hata oluştu: \(error)")
        }
        
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y < 0 {
            refreshData()
        }
    }
    
    
    func saveContext() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newPerson"), object: nil)
    }
    
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = Person.fetchRequest() as NSFetchRequest<Person>
        do {
            person = try context.fetch(fetchRequest)
            print(person)
        } catch let error {
            print("Error :  \(error.localizedDescription).") }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CustomTableViewCell else {
               return UITableViewCell()
        }
        
        let item = person[indexPath.row]
        
        let name = item.name
        let surname = item.surname
        
        cell.lineLabel.text = "\(1 + indexPath.row)"
        
        cell.nameLabel.text = (name ?? "") + " " + (surname ?? "")
        cell.locationLabel.text = "Location: " + (item.location ?? "")
        cell.epostaLabel.text = "Email: " + (item.eposta ?? "")
        cell.pnumberLabel.text = "Phone Number: " + (item.pnumber ?? "")
        cell.mdetailsLabel.text = item.mdetails
        
//
        cell.mdetailsLabel.numberOfLines = 0
        
        if let date = item.dateofbirthday {
            cell.birthdayLabel.text = "BDay: " + dateFormatter.string(from: date)
        } else {
            print("DatePicker empty")
        }
        
        let images = item
        if let imageData = images.img, let image = UIImage(data: imageData) {
            cell.img?.image = image
            cell.img.layer.borderWidth = 2.0
            cell.img.layer.borderColor = UIColor.black.cgColor
        }
        
        cell.favButton.isSelected = item.fav
        cell.favoriteButtonTapped = {
            item.fav.toggle()
            self.saveContext()
            print("\(item.name ?? "") \(item.surname ?? "") Favorites Addes : \(item.fav.description)")
            tableView.reloadData()
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return person.count
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let entity = person[indexPath.row]
            let alert = UIAlertController(title: "Are you sure?", message: "Delete ? ", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "No", style: .cancel)
            let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                context.delete(entity)
                self.person.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.saveContext()
                
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            present(alert, animated: true)
        }
    }
}

