//
//  DetailsViewController.swift
//  Storek 
//
//  Created by Abdelrahman Shera on 28/08/2023.
//

import UIKit
import Kingfisher
import Cosmos
import CoreData



class DetailsViewController: UIViewController , UICollectionViewDelegate {
    
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var buttonPresed = false
    
//    MARK: - productDetails
    var brandBox = String()
    var descriptionBox = String()
    var stockBox = Int()
    var priceBox = Int()
    var discountBox = Double()
    var ratingBox = Double()
    var imagesBox = [String]()
    var productNameBox = String()
    var productImageBox = String()
    
    
    //    MARK: - outlets
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    @IBOutlet weak var imageCV: UICollectionView!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var CosmosView: CosmosView!
    @IBOutlet weak var LoveButton: UIButton!
    
    //    MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
        Check()
    }

    @IBAction func loveButtonPressed(_ sender: UIButton) {
        buttonPresed.toggle()
        LoveButtonState()
    }
    func setupCollectionView(){
        imageCV.delegate = self
        imageCV.dataSource = self
    }
    
    func setupUI(){
        brandLabel.text = brandBox
        descriptionLabel.text =  descriptionBox
        
        if stockBox > 10 {
            stockLabel.text = "In Stock"
            stockLabel.textColor = UIColor(named:"instock")
        }else{
            stockLabel.text = "\(String(stockBox)) left in stock - order soon "
            stockLabel.textColor = UIColor(named: "instockred")
        }
        
        discountLabel.text = "-\(String(discountBox)) %"
        priceLabel.text = " \(String(priceBox)) $"
        
        //rating
        CosmosView.rating = ratingBox
        CosmosView.settings.fillMode = .precise
        CosmosView.isUserInteractionEnabled = false
        
        bigImageView.kf.setImage(with: URL(string:imagesBox[0]))
        bigImageView.layer.cornerRadius = 10
    }
   
    func save() {
        let entity = NSEntityDescription.entity(forEntityName: "FavouriteData", in: context)
        let favouriteItem = NSManagedObject(entity: entity!, insertInto: context)
        
        favouriteItem.setValue(productNameBox, forKey: "productName")
        
        if let imageUrl = URL(string: productImageBox) {
            URLSession.shared.dataTask(with: imageUrl) {(imageData, response, error) in
                if let safeImageData = imageData {
                        favouriteItem.setValue(safeImageData, forKey: "productImage")
                        do {
                            try self.context.save()
                        } catch {
                            print("error 4 ")
                        }
                }
            }.resume()
        }
    }
    
    func delete(){
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteData")
        let selectedData = NSPredicate(format: "productName ==  %@", productNameBox )
        fetchRequest.predicate = selectedData
        do {
            let DataSet = try context.fetch(fetchRequest)
            context.delete(DataSet[0])
            try context.save()
        }catch{
            print("error 5")
        }
    }
    
//    func read(){
//
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteData")
//        do {
//            let DataSet = try context.fetch(fetchRequest)
//            for Data in DataSet {
//                print(" \(Data.value(forKey: "productName") as! String )")
//            }
//
//        }catch{
//            print("error 6")
//        }
//
//    }
    
    func Check(){
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavouriteData")
        do {
            let DataSet = try context.fetch(fetchRequest)
            for productname in DataSet {
                if productname.value(forKey: "productName") as! String == self.productNameBox {
                        LoveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                        buttonPresed = true
                        break
                }
            }
            if !buttonPresed {
                LoveButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }catch{
            print("error 7")
        }
    }
    
    func LoveButtonState(){
        if buttonPresed{
            // save to coredata
            save()
            LoveButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            let alert = UIAlertController(title: "Added to Favourite List", message: nil, preferredStyle: .alert)
                   present(alert, animated: true, completion: nil)
                   
                   // Dismiss the alert
                   Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
                       alert.dismiss(animated: true, completion: nil)
                   }
        }else{
            //check if it in coreData if ture delete else nothing
            delete()
            LoveButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}

//    MARK: - collectionViewDataSource

extension DetailsViewController:  UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesBox.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageViewCell", for: indexPath) as! imageViewCell
        let imageUrl = URL(string: imagesBox[indexPath.row])
        cell.smallimageView.kf.setImage(with: imageUrl)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = URL(string: imagesBox[indexPath.row])
        DispatchQueue.main.async {
            self.bigImageView.kf.setImage(with: selectedImage)
            self.bigImageView.layer.cornerRadius = 10
        }
    }
}
