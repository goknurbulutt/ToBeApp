//
//  ListViewController.swift
//  ToBe
//
//  Created by Göknur Bulut on 23.07.2023.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var tableView: UITableView!
    var nameSeries = [String]()
    var idSeries = [UUID]()
    var chosenPlaceName = ""
    var chosenPlaceİd : UUID?




    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let backgroundImage = UIImage(named: "arkaplan_gorseli")

                
        let backgroundImageView = UIImageView(frame: tableView.frame)
                backgroundImageView.image = backgroundImage
                backgroundImageView.contentMode = .scaleAspectFill
                tableView.backgroundView = backgroundImageView
                backgroundImageView.contentMode = .scaleAspectFill
        
       
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonClicked) )
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name:NSNotification.Name("newPlaceCreated") , object: nil)
    }
    
    @objc func getData() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        request.returnsObjectsAsFaults = false
        
        do{
            
            let results = try context?.fetch(request)
            
            if results!.count > 0 {
                
                nameSeries.removeAll(keepingCapacity: false)
                idSeries.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String {
                        nameSeries.append(name)
                        
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idSeries.append(id)
                    }
                }
                
                tableView.reloadData()
            }
        } catch{
            print("Hata")
        }
        
    }
    
    
    
    @objc func plusButtonClicked(){
        chosenPlaceName = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameSeries.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameSeries[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chosenPlaceName = nameSeries[indexPath.row]
        chosenPlaceİd = idSeries[indexPath.row]
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.chosenName = chosenPlaceName
            destinationVC.chosenİd = chosenPlaceİd
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
            let uuidString = idSeries[indexPath.row].uuidString
            
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idSeries[indexPath.row]{
                                context.delete(result)
                                nameSeries.remove(at: indexPath.row)
                                idSeries.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    
                                }
                                 
                                break
                            }
                        }
                    }
                }
            }catch{
                
            }
            
            
            
        }
    }
    
    
    
    
    
    
    
    
    
}



    
    

