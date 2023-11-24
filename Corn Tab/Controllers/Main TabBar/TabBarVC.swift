//
//  TabBarVC.swift
//  Corn Tab
//
//  Created by StarsDev on 11/07/2023.

import UIKit

class TabBarVC: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var dineInTabbar: UITabBarItem!
    @IBOutlet weak var takeaWayTabbar: UITabBarItem!
    @IBOutlet weak var dashboardTabbar: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableViewBtn: UIButton!
    @IBOutlet weak var collectionViewBtn: UIButton!
    @IBOutlet weak var loactionLbl: UILabel!
    @IBOutlet weak var attendNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var pendingOrder: UILabel!
    //MARK: Variables
    //For refresh page
    var refreshControl=UIRefreshControl()
    var orderDetail = [String]()
    var customerIDsString = ""
    var distributionName = ""
    var userName = ""
    var workingDate = ""
    var dataSource: [Row] = []
    var timer: Timer?
    //MARK: Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        tableView.isHidden = true
        attendNameLbl.text = userName
        loactionLbl.text = distributionName
        dateLbl.text =  workingDate
        startTimer()
        refreshControl.addTarget(self, action: #selector(TabBarVC.refreshPendingRequests), for: .valueChanged)
collectionView.addSubview(refreshControl)
        makePOSTRequest()
        
    }
    override func viewWillAppear(_ animated: Bool) {
//        makePOSTRequest()
    }
    //MARK: Button Actions
    @IBAction func tableViewBtn(_ sender: UIButton) {
        tableView.isHidden = false
        collectionView.isHidden = true
        tableViewBtn.tintColor = #colorLiteral(red: 0.9657021165, green: 0.4859523773, blue: 0.2453393936, alpha: 1)
        collectionViewBtn.tintColor = #colorLiteral(red: 0.4576840401, green: 0.4979689717, blue: 0.5107063055, alpha: 1)
    }
    @IBAction func collectionViewBtn(_ sender: UIButton) {
        collectionView.isHidden = false
        tableView.isHidden = true
        tableViewBtn.tintColor = #colorLiteral(red: 0.4576840401, green: 0.4979689717, blue: 0.5107063055, alpha: 1)
        collectionViewBtn.tintColor = #colorLiteral(red: 0.9657021165, green: 0.4859523773, blue: 0.2453393936, alpha: 1)
    }
    @objc func refreshPendingRequests(_ sender: Any){
        makePOSTRequest()
    }
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDateAndTime), userInfo: nil, repeats: true)
    }
    @objc func updateDateAndTime() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
        let dateString = dateFormatter.string(from: currentDate)
        timeLbl.text = dateString
    }
//    @objc func eidtBtnTapped(sender: UIButton) {
//        let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController
//        tabBarController?.delegate = self
//        let navigationController = UINavigationController(rootViewController: tabBarController!)
//        navigationController.modalPresentationStyle = .fullScreen
//        if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 3 {
//            tabBarController?.selectedIndex = 2
//        }
//        self.present(navigationController, animated: false, completion: nil)
//    }
    @objc func eidtBtnTapped(_ sender: UIButton) {
            let jsonData = self.orderDetail[sender.tag].data(using: .utf8)
            do {
                    // Use JSONDecoder to decode the data into an array of OrderItem
                let orderItems = try JSONDecoder().decode([OrderItem].self, from: jsonData!)
                    // Now 'orderItems' contains an array of decoded OrderItem objects
                var savedItems = [[String: String]]()
                var allOrders = [OrderItem]()
                var selectedAddOns: [String] = []
                var selectedAddOnPrices: [Double] = []
                allOrders = orderItems
                for i in 0...allOrders.count - 1{
                    for j in 0...orderItems.count - 1{
                        if allOrders[i].id == orderItems[j].modifierParentID{
                            let addOnInfo = "\(orderItems[j].name) (\(orderItems[j].price ?? 0))"
                            selectedAddOns.append(addOnInfo)
                            selectedAddOnPrices.append(orderItems[i].price ?? 0)
                        }
                    }
                }
                let totalAddOnPrice = selectedAddOnPrices.reduce(0, +)
                
                let selectedAddOnsString = selectedAddOns.joined(separator: "\n")
                    for orderItem in orderItems {
                        //print("OrderID: \(orderItem.orderID), Name: \(orderItem.name), Price: \(orderItem.price)")
                        let totalPrice = Int((orderItem.price ?? 0) + totalAddOnPrice)
                        if orderItem.isHasAddsOn{
                            let newItem: [String: String] = [
                                "title": orderItem.name,
                                "quantity": "\(Int(orderItem.qty ?? 0))",
                                "price" : "\(totalPrice)",
                                "selectedAddOns": "\(selectedAddOnsString)",
                            ]
                            
                            savedItems.append(newItem)
                        }
                        else if orderItem.isAddsOn{
                            
                        }
                        else{
                            let newItem: [String: String] = [
                                "title": orderItem.name,
                                "quantity": "\(Int(orderItem.qty ?? 0))",
                                "price" : "\(orderItem.price ?? 00)",
                                "selectedAddOns": "",
                            ]
                            
                            savedItems.append(newItem)
                        }
                    }
                
                UserDefaults.standard.set(savedItems, forKey: "addedItems")
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            
//            let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController
//            tabBarController?.delegate = self
//            let navigationController = UINavigationController(rootViewController: tabBarController!)
//            navigationController.modalPresentationStyle = .fullScreen
//            if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 3 {
//                tabBarController?.selectedIndex = 2
//            }
//            self.present(navigationController, animated: false, completion: nil)
//        }
        // Pass information to the next view controller
            let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController

            // Assuming the next view controller is at index 2 (change it according to your actual setup)
            if let nextViewController = tabBarController?.viewControllers?[2] as? OrderDetailsVC {
                nextViewController.updatedButtonText = "Updated Order"
            }

            tabBarController?.delegate = self
            let navigationController = UINavigationController(rootViewController: tabBarController!)
            navigationController.modalPresentationStyle = .fullScreen
            if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 3 {
                tabBarController?.selectedIndex = 2
            }
            
            // Present the navigation controller
            self.present(navigationController, animated: false, completion: nil)
        }
}
//MARK: Helper function to make POST request
extension TabBarVC {
    func  makePOSTRequest() {
        // Define the API endpoint URL
        let endpoint = APIConstants.Endpoints.dashBoard
        let urlString = APIConstants.baseURL + endpoint
        guard let apiUrl = URL(string: urlString) else {
            print("Invalid URL.")
            return
        }
        // Define the request parameters as a dictionary
        let parameters: [String: Any] = [
            "SpName": "uspGetPendingOrderOfflineMode",
            "Parameters": [
                "DistributorID": "1"]
        ]
        // Convert parameters to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            // Create a URL request
            var request = URLRequest(url: apiUrl)
            request.httpMethod = "POST"
            let connString = UserDefaults.standard.string(forKey: "connectString")
            let accessToken = UserDefaults.standard.string(forKey: "Access_Token") ?? ""
            request.setValue(connString, forHTTPHeaderField: "x-conn")
            request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            // Create a URLSession data task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print("Error: No data received")
                    return
                }
                // Decode the response into the DashBoardModel
                do {
                    let decoder = JSONDecoder()
                    let dashboardModel = try decoder.decode(DashBoardModel.self, from: data).rows
                    let pendingOrder = try decoder.decode(DashBoardModel.self, from: data).totalLength
                    print(dashboardModel) // Check if the decoding is successful and the model is correctly populated
                    self.dataSource = dashboardModel
                    // Reload the collection view on the main thread
                    DispatchQueue.main.async {
                        let date = dashboardModel.first?.createDateTime.components(separatedBy: "T")
                        print(date?[1] ?? "")
                        self.dateLbl.text = date?[0] ?? ""
                        self.pendingOrder.text = "\(pendingOrder)"
                        self.refreshControl.endRefreshing()
                        self.collectionView.reloadData()
                        self.tableView.reloadData()
                    }
                } catch let error {
                    print("Error decoding API response: \(error)")
                }
            }
            task.resume()
        } catch {
            print("Error converting parameters to JSON data: \(error)")
        }
    }
}
//MARK: Collection View
extension TabBarVC:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TabBarCVCell
        let rowData = dataSource[indexPath.item]
        if let tableDetailData = rowData.tableDetail?.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: tableDetailData, options: []) as? [[String: Any]] {
            
            // Extract table names and join them with a "+"
            let tableNames = jsonArray.compactMap { $0["TableName"] as? String }
            let concatenatedNames = tableNames.joined(separator: "+")

            cell.tableNoLbl.text = concatenatedNames
        } else {
            cell.tableNoLbl.text = "" // Handle invalid JSON data or missing TableName
        }

        cell.orderNoLbl.text = rowData.orderNO
        cell.timeLbl.text = rowData.createDateTime
//        cell.tableNoLbl.text = rowData.tableDetail
        self.orderDetail.append(rowData.orderDetail ?? "")
                cell.eidtBtn.tag = indexPath.item
        cell.eidtBtn.addTarget(self, action: #selector(eidtBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
}
//MARK: TableView
extension TabBarVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TabBarTVCell
        let rowData = dataSource[indexPath.section]
        if let tableDetailData = rowData.tableDetail?.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: tableDetailData, options: []) as? [[String: Any]] {
            // Extract table names and join them with a "+"
            let tableNames = jsonArray.compactMap { $0["TableName"] as? String }
            let concatenatedNames = tableNames.joined(separator: "+")

            cell.tableNoLbl.text = concatenatedNames
        } else {
            cell.tableNoLbl.text = "" // Handle invalid JSON data or missing TableName
        }
        cell.orderNoLbl.text = rowData.orderNO
        cell.timeLbl.text = rowData.createDateTime
//        cell.tableNoLbl.text = rowData.tableDetail
        let spacing: CGFloat = 20
        cell.separatorInset = UIEdgeInsets(top: 0, left: spacing, bottom: 100, right: spacing)
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
}
//MARK:  Extension Tabbar
extension TabBarVC:UITabBarControllerDelegate ,UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == dineInTabbar {
            let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController
            tabBarController?.delegate = self
            let navigationController = UINavigationController(rootViewController: tabBarController!)
            navigationController.modalPresentationStyle = .fullScreen
            if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 1 {
                tabBarController?.selectedIndex = 1
            }
            self.present(navigationController, animated: false, completion: nil)
        }
        else if item == takeaWayTabbar {
            let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController
            tabBarController?.delegate = self
            let navigationController = UINavigationController(rootViewController: tabBarController!)
            navigationController.modalPresentationStyle = .fullScreen
            if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 3 {
                tabBarController?.selectedIndex = 3
            }
            if var viewControllers = tabBarController?.viewControllers {
                viewControllers.remove(at: 1)
                tabBarController?.viewControllers = viewControllers
            }
            self.present(navigationController, animated: false, completion: nil)
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            tabBarController.dismiss(animated: false,completion: {
                UserDefaults.standard.removeObject(forKey: "addedItems")
                self.tabBar.selectedItem = self.dashboardTabbar
            })
        }
    }
}
