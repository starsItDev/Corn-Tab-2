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
    var tableIDs: [String] = []
    var isActivityIndicatorVisible = false
    var orderDetail = [String]()
    var tableDetail = [String]()
    var customerIDsString = ""
    var distributionName = ""
    var userName = ""
    var workingDate = ""
    var dataSource: [Row] = []
    var timer: Timer?
    var refreshControl: UIRefreshControl!
    var orderIDA: String?
    //MARK: Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.delegate = self
        tableView.isHidden = true
        attendNameLbl.text = userName
        loactionLbl.text = distributionName
        dateLbl.text =  workingDate
        print(workingDate)
        UserDefaults.standard.set(workingDate, forKey: "savedWorkingDate")
        startTimer()
        // Initialize UIRefreshControl
           refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
           collectionView.refreshControl = refreshControl
        makePOSTRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        makePOSTRequest()
    }
    @objc func refreshData() {
        // Perform your data refresh logic here, for example, make the POST request again
        makePOSTRequest()
    }

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
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDateAndTime), userInfo: nil, repeats: true)
    }
    @objc func updateDateAndTime() {
        let currentDate = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm:ss a"
        let dateString = timeFormatter.string(from: currentDate)
        timeLbl.text = dateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
//        dateLbl.text = dateFormatter.string(from: currentDate)
    }
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
                 var modifierParentIds = [Int: [String]]()
                 var totalAddOnPrices = [Int: [Double]]()
                 allOrders = orderItems
                 for i in 0...allOrders.count - 1{
                     for j in 0...orderItems.count - 1{
                         if allOrders[i].id == orderItems[j].modifierParentID{
                             
                             let addOnInfo = "\(orderItems[j].name) (\(orderItems[j].price ?? 0))"
                             selectedAddOns.append(addOnInfo)
                             selectedAddOnPrices.append(orderItems[j].price ?? 0)
                             modifierParentIds[orderItems[j].modifierParentID] = selectedAddOns
                             totalAddOnPrices[orderItems[j].modifierParentID] = selectedAddOnPrices
                         }
                     }
                     selectedAddOns.removeAll()
                     selectedAddOnPrices.removeAll()
                 }
                 let totalAddOnPrice = selectedAddOnPrices.reduce(0, +)
                 
                 //let selectedAddOnsString = selectedAddOns.joined(separator: "\n")
                 for orderItem in orderItems {
                     //print("OrderID: \(orderItem.orderID), Name: \(orderItem.name), Price: \(orderItem.price)")
                     var totalPrice = Int((orderItem.price ?? 0) + totalAddOnPrice)
                     if orderItem.isHasAddsOn{
                         var str = String()
                         if let addOnIds = modifierParentIds[orderItem.id] {
                             str = addOnIds.joined(separator: "\n")
                         }
                         
                         if let addOnPrices = totalAddOnPrices[orderItem.id] {
                             totalPrice += Int(addOnPrices.reduce(0.0, +))
                         }
                         let newItem: [String: String] = [
                             "Title": orderItem.name,
                             "Qty": "\(Int(orderItem.qty ?? 0))",
                             "Price" : "\(totalPrice)",
                             "SelectedAddOns": "\(str)",
                             "ID": "\(orderItem.id)"
                         ]
                         
                         savedItems.append(newItem)
                     }
                     else if orderItem.isAddsOn{
                         
                     }
                     else{
                         let newItem: [String: String] = [
                             "Title": orderItem.name,
                             "Qty": "\(Int(orderItem.qty ?? 0))",
                             "Price" : "\(orderItem.price ?? 0)",
                             "SelectedAddOns": "",
                             "ID": "\(orderItem.id)"
                         ]
                         
                         savedItems.append(newItem)
                     }
                     
                 }
                 let coverTable = dataSource[sender.tag].coverTable
                 let orderNo = dataSource[sender.tag].orderNO
                 let orderIDA = dataSource[sender.tag].orderID
                 let dateTime = dataSource[sender.tag].createDateTime?.split(separator: "T")
                 let jsonForTable = self.tableDetail[sender.tag].data(using: .utf8)
                 do{
                     let tableItems = try JSONDecoder().decode([TableItem].self, from: jsonForTable!)
                     if let firstTableDetail = tableItems.first {
                         let tableID = firstTableDetail.TableID
                         let tableName = firstTableDetail.TableName
                         let newItem: [String: Any] = [
        
                            "OrderNo": orderNo ,
                             "TableCover": coverTable ?? "",
                             "TableName" : tableName ?? "",
                             "Date": String(dateTime?[0] ?? ""),
                             "Time": String(dateTime?[1] ?? ""),
                             "isEdit": "\(true)"
                         ]
                         UserDefaults.standard.set(newItem, forKey: "TableContent")
                     }
                 } catch{
                     print("Error decoding JSON: \(error)")
                 }
                 UserDefaults.standard.set(savedItems, forKey: "addedItems")
             } catch {
                 print("Error decoding JSON: \(error)")
             }
             
            let orderIDA = dataSource[sender.tag].orderID
            let tabBarController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeTabBar") as? UITabBarController
            if let nextViewController = tabBarController?.viewControllers?[2] as? OrderDetailsVC {
                nextViewController.updatedButtonText = "Update Order"
                // Convert Int to String before assignment
                nextViewController.orderID = String(orderIDA)
                print(orderIDA)
                
            }
            tabBarController?.delegate = self
             let navigationController = UINavigationController(rootViewController: tabBarController!)
             navigationController.modalPresentationStyle = .fullScreen
             if let viewControllers = tabBarController?.viewControllers, viewControllers.count >= 3 {
                 tabBarController?.selectedIndex = 2
                 //tabBarController.tableNumberText = tableNoLbl.text
                 //tabBarController.coverTableText = coverTableLbl.text
             }
             self.present(navigationController, animated: false, completion: nil)
         }
}
//MARK: Helper function to make POST request
extension TabBarVC {
    func  makePOSTRequest() {
        let endpoint = APIConstants.Endpoints.dashBoard
        let urlString = APIConstants.baseURL + endpoint
        guard let apiUrl = URL(string: urlString) else {
            return
        }
        let parameters: [String: Any] = [
            "SpName": "uspGetPendingOrderOfflineMode",
            "Parameters": [
                "DistributorID": "1"]
        ]
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
                    self.dataSource = dashboardModel
                    DispatchQueue.main.async {
                        let date = dashboardModel.first?.createDateTime?.components(separatedBy: "T")
//                        self.dateLbl.text = date?[0] ?? ""
                        if let dateString = date?[0] {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd-MM-yyyy"
                            if let formattedDate = dateFormatter.date(from: dateString) {
                                self.dateLbl.text = dateFormatter.string(from: formattedDate)
                            }
                        }
                        self.pendingOrder.text = "\(pendingOrder)"
                        self.tableIDs = dashboardModel.compactMap { $0.tableID }
                        self.collectionView.reloadData()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
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
            let tableNames = jsonArray.compactMap { $0["TableName"] as? String }
            let concatenatedNames = tableNames.joined(separator: "+")
            cell.tableNoLbl.text = concatenatedNames
        } else {
            cell.tableNoLbl.text = ""
        }

        cell.orderNoLbl.text = rowData.orderNO

        var date = rowData.createDateTime?.components(separatedBy: "T")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        
        if let newTime = timeFormatter.date(from: date?[1] ?? "") {
            timeFormatter.dateFormat = "h:mm a"
            if let formattedTime = timeFormatter.string(for: newTime) {
                date?[1] = formattedTime
            } else {
                print("Failed to format time.")
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let newDate = dateFormatter.date(from: date?[0] ?? "") {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let formattedDate = dateFormatter.string(for: newDate) {
                date?[0] = formattedDate
            } else {
                print("Failed to format date.")
            }
        }

        cell.timeLbl.text = (date?[0] ?? "") + " " + (date?[1] ?? "")

        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
        
        if let currentDate = displayDateFormatter.date(from: cell.timeLbl.text ?? "") {
            // Calculate time ago
            let timeAgo = calculateTimeAgo(from: currentDate)
            cell.timeLbl.text = timeAgo
        }
        //        cell.tableNoLbl.text = rowData.tableDetail
        self.orderDetail.append(rowData.orderDetail ?? "")
        self.tableDetail.append(rowData.tableDetail ?? "")
        cell.eidtBtn.tag = indexPath.item
        cell.eidtBtn.addTarget(self, action: #selector(eidtBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    func calculateTimeAgo(from date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())

        if let year = components.year, year > 0 {
            return "\(year) year\(year == 1 ? "" : "s") ago"
        } else if let month = components.month, month > 0 {
            return "\(month) month\(month == 1 ? "" : "s") ago"
        } else if let day = components.day, day > 0 {
            return "\(day) day\(day == 1 ? "" : "s") ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else if let second = components.second, second > 0 {
            return "\(second) second\(second == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 270, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
//MARK: Table  View
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

        var date = rowData.createDateTime?.components(separatedBy: "T")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        
        if let newTime = timeFormatter.date(from: date?[1] ?? "") {
            timeFormatter.dateFormat = "h:mm a"
            if let formattedTime = timeFormatter.string(for: newTime) {
                date?[1] = formattedTime
            } else {
                print("Failed to format time.")
            }
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let newDate = dateFormatter.date(from: date?[0] ?? "") {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let formattedDate = dateFormatter.string(for: newDate) {
                date?[0] = formattedDate
            } else {
                print("Failed to format date.")
            }
        }

        cell.timeLbl.text = (date?[0] ?? "") + " " + (date?[1] ?? "")

        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
        
        if let currentDate = displayDateFormatter.date(from: cell.timeLbl.text ?? "") {
            // Calculate time ago
            let timeAgo = calculateTimeAgo(from: currentDate)
            cell.timeLbl.text = timeAgo
        }
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
            if let selectionVC = tabBarController?.viewControllers?[1] as? SelectionVC {
                       selectionVC.receivedTableIDs = tableIDs
                   }
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
            let addedItems = UserDefaults.standard.array(forKey: "addedItems") as? [[String: String]] ?? []

            if addedItems.isEmpty {
                // addedItems is empty, dismiss tabBarController without showing an alert
                tabBarController.dismiss(animated: false, completion: {
                    UserDefaults.standard.removeObject(forKey: "addedItems")
                    self.tabBar.selectedItem = self.dashboardTabbar
                })
            } else {
                // addedItems is not empty, show an alert
                let alert = UIAlertController(title: "Alert", message: "Do you want to discard your Order?", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    // Dismiss tabBarController and perform other actions
                    tabBarController.dismiss(animated: false, completion: {
                        UserDefaults.standard.removeObject(forKey: "addedItems")
                        self.tabBar.selectedItem = self.dashboardTabbar
                    })
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    // Handle cancel button tap (you can leave it empty or perform additional actions)
                    print("")
                }
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                // Present the alert
                tabBarController.present(alert, animated: false, completion: nil)
            }
        }
    }
}
