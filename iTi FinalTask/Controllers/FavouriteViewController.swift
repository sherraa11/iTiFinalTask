//
//  FavouriteViewController.swift
//  Storek 
//
//  Created by Abdelrahman Shera on 28/08/2023.
//

import UIKit
import CoreData

class FavouriteViewController: UIViewController , UITableViewDelegate {
    
    //    MARK: - properties
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var favImagesBox = [UIImage]()
    var favPfoductsBox = [String]()
    
    
    @IBOutlet weak var FavTableView: UITableView!
    
    //    MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    override func viewDidAppear(_ animated: Bool) {
        read()
    }
    
    
    private func setupTableView(){
        FavTableView.delegate = self
        FavTableView.dataSource = self
    }
    
    func read() {
        
        favPfoductsBox.removeAll()
        favImagesBox.removeAll()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteData")
        do {
            let DataSet = try context.fetch(fetchRequest)
            for Data in DataSet {
                let productNameToAdd = Data.value(forKey: "productName") as! String
                favPfoductsBox.append(productNameToAdd)
                
                if let imageDataToAdd = Data.value(forKey: "productImage") as? Data {
                    favImagesBox.append(UIImage(data: imageDataToAdd)!)
                }
            }
            DispatchQueue.main.async {
                self.FavTableView.reloadData()
            }
        } catch {
            print("error 2")
        }
    }
    
    func deletFavItem(_ productName : String ,indexPath : IndexPath){
        
        // Remove the item from your data source
        self.favPfoductsBox.remove(at: indexPath.row)
        self.favImagesBox.remove(at: indexPath.row)
        
        // deleting the row from the table view
        FavTableView.deleteRows(at: [indexPath], with: .fade)
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteData")
        fetchRequest.predicate = NSPredicate(format: "productName == %@", productName)
        
        do {
            // delete from coreData
            let DataSet = try self.context.fetch(fetchRequest)
            if let dataToRemove = DataSet.first as? NSManagedObject {
                self.context.delete(dataToRemove)
                try self.context.save()
            }
        } catch {
            print("error 3")
        }
    }
}
//    MARK: - dataSource

extension FavouriteViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favPfoductsBox.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favouriteCell", for: indexPath) as! FavoutiteViewCell
        cell.favouriteProductName.text = favPfoductsBox[indexPath.row]
        cell.favouriteProductImage.layer.cornerRadius = 65/2
        // to solve error when it have two indces
        if indexPath.row < favImagesBox.count {
            cell.favouriteProductImage.image = favImagesBox[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let productNameToRemove = favPfoductsBox[indexPath.row]
            
            // Create a confirmation alert
            let confirmationAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deletFavItem(productNameToRemove, indexPath: indexPath)
            }))
            
            // Present the confirmation alert
            present(confirmationAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

