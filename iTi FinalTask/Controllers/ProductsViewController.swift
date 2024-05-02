//
//  ProductsViewController.swift
//  Storek 
//
//  Created by Abdelrahman Shera on 28/08/2023.
//

import UIKit
import Kingfisher
import Reachability
import Dodo


class ProductsViewController: UIViewController , UITableViewDelegate {
    
    //    MARK: - properties
    var reachability: Reachability?
    let urlString = "https://dummyjson.com/products"
    let activityIndicator = UIActivityIndicatorView(style: .large)
    var dataArray = [Dictionary<String,Any>]()
    var productData = Dictionary<String,Any>()
    var counter = Int()
    var products = [String]()
    var images = [String]()
    
    //    MARK: - outlets
    @IBOutlet weak var TabelView: UITableView!
    
    
    //    MARK: - methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupReachability()
    }
    
    private func setupReachability(){
        do {
            reachability = try Reachability()
            try reachability?.startNotifier()
        } catch {
            print("Error initializing reachability")
        }
        reachability?.whenReachable = {  reachability in
            self.netwrokReachable()
        }
        reachability?.whenUnreachable = {  reachability in
            self.networkUnreachable()
        }
    }
    
    private func netwrokReachable(){
        viewActivityIndicator()
        perforRequest(self.urlString)
        view.dodo.style.bar.hideAfterDelaySeconds = 0.5
        view.dodo.topAnchor = self.view.safeAreaLayoutGuide.topAnchor
        view.dodo.success("Connected")
    }
    private func networkUnreachable(){
        products.removeAll()
        images.removeAll()
        TabelView.reloadData()
        activityIndicator.stopAnimating()
        view.dodo.topAnchor = self.view.safeAreaLayoutGuide.topAnchor
        view.dodo.style.bar.hideAfterDelaySeconds = 0
        view.dodo.error("no internet connection")
    }
    
    private func setupTableView(){
        TabelView.delegate = self
        TabelView.dataSource = self
    }
    
    private func viewActivityIndicator(){
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}
//    MARK: - dataSource
extension ProductsViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell" , for: indexPath) as! ProductCell
        let url = URL(string: images[indexPath.row])
        cell.productImage.layer.cornerRadius = 65/2
        cell.productName.text = products[indexPath.row]
        cell.productImage.kf.setImage(with: url)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailsView = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        let selectedProduct = dataArray[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        //  pass to empty variables
        detailsView.brandBox = selectedProduct["brand"] as! String
        detailsView.descriptionBox = selectedProduct["description"] as! String
        detailsView.discountBox = selectedProduct["discountPercentage"] as! Double
        detailsView.imagesBox = selectedProduct["images"] as! [String]
        detailsView.priceBox = selectedProduct["price"] as! Int
        detailsView.ratingBox = selectedProduct["rating"] as! Double
        detailsView.stockBox = selectedProduct["stock"] as! Int
        
        //  coreData to view again
        detailsView.productImageBox = selectedProduct["thumbnail"] as! String
        detailsView.productNameBox = selectedProduct["title"] as! String
        
        navigationController?.pushViewController(detailsView, animated: true)
        
    }
    
    //    MARK: - Api call
    func perforRequest(_ urlString : String){
        let url = URL(string:urlString )
        let request = URLRequest(url: url!)
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {( data, respose, error ) in
            do {
                if let safeData = data{
                    let parsJSON = try JSONSerialization.jsonObject(with: safeData) as! Dictionary<String,Any>
                    self.dataArray = parsJSON["products"] as! [Dictionary<String,Any>]
                    self.productData = self.dataArray[self.counter]
                    self.dataArray.forEach { product in
                        self.products.append(product["title"] as! String)
                        self.images.append(product["thumbnail"] as! String)
                    }
                    DispatchQueue.main.async{
                        self.TabelView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
            catch{
                print("error 1")
            }
        }
        task.resume()
    }
}

