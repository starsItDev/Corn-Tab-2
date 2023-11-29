//
//  SelectionVC.swift
//  Corn Tab
//
//  Created by StarsDev on 12/07/2023.

import UIKit
class SelectionVC: UIViewController{
    // MARK: Outlets
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var itemCountTxt: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Var
    var itemCount = 0
    var receivedItemCount: Int = 0
    let textFieldDelegateHelper = TextFieldDelegateHelper()
    var apiResponse: [MasterDetailRow] = []
    var parsedRows: [[MasterDetailRow]] = []
    var sectionNames: [String] = []
    var itemIDToSectionID: [Int: Int] = [:]
    var sectionNameToID: [String: Int] = [:]
    var selectedTableNumbers: [String] = []
    var selectedIndexPaths: Set<IndexPath> = []
    let data = ["Item 1", "Item 2", "Item 3", "Item 4"]
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.reloadData()
        apiCalling()
        itemCountTxt.keyboardType = .numberPad
        UserDefaults.standard.removeObject(forKey: "SelectedTableIDs")
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    private func setupUI() {
            navigationController?.setNavigationBarHidden(true, animated: false)
            let boldFont = UIFont.boldSystemFont(ofSize: 20)
            let attributes = [NSAttributedString.Key.font: boldFont]
            segments.setTitleTextAttributes(attributes, for: .normal)
            textFieldDelegateHelper.configureTapGesture(for: view)
            itemCountTxt.delegate = textFieldDelegateHelper
            searchBar.delegate = self
        }
// MARK: Actions
    
        func apiCalling(){
            let loader = UIActivityIndicatorView(style: .large)
                loader.center = view.center
                loader.startAnimating()
                view.addSubview(loader)
            var sectionNameToID: [String: Int] = [:]
            
            APIManager.makePOSTRequest { dashboardModelArray in
                guard dashboardModelArray.count > 1 else {
                    print("Error: dashboardModelArray has insufficient elements.")
                    loader.stopAnimating()
                    loader.removeFromSuperview()
                    return
                }
                let rowItemData = dashboardModelArray[1]
                            
                for dashboardModel in dashboardModelArray {
                    for row in dashboardModel {
                            if let sectionID = row.floorID, let sectionName = row.floorName {
                                if !sectionNameToID.keys.contains(sectionName.rawValue) {
                                    sectionNameToID[sectionName.rawValue] = sectionID
                                    self.sectionNames.append(sectionName.rawValue)
                                }
                            if let itemID = row.floorID {
                                self.itemIDToSectionID[itemID] = sectionID
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                            loader.stopAnimating()
                            loader.removeFromSuperview()
                            self.apiResponse = rowItemData
                            self.segments.removeAllSegments()
                            self.sectionNameToID = sectionNameToID

                            for (index, sectionName) in self.sectionNames.enumerated() {
                                self.segments.insertSegment(withTitle: sectionName, at: index, animated: false)
                            }

                            self.segments.selectedSegmentIndex = 0
                            self.collectionView.reloadData()
                        }
                    }
                }

    @IBAction func minusButton(_ sender: UIButton) {
        if let currentItemCount = Int(itemCountTxt.text ?? "0") {
            itemCount = max(0, currentItemCount - 1)
            updateItemCountLabel() // Update the item count label
            sendItemCountToDineInVC()
        }
    }
    @IBAction func plusButton(_ sender: UIButton) {
        if let currentItemCount = Int(itemCountTxt.text ?? "0") {
            itemCount = currentItemCount + 1
            updateItemCountLabel() // Update the item count label
            sendItemCountToDineInVC()
        }
    }
    func updateItemCountLabel() {
        itemCountTxt.text = String(itemCount)
    }
    @IBAction func segmentController(_ sender: UISegmentedControl) {
        selectedIndexPaths.removeAll()
        collectionView.reloadData()
    }
    func sendItemCountToDineInVC() {
        // Assuming that DineInVC is the fourth tab's view controller
        if let tabBarController = self.tabBarController,
           let dineInVC = tabBarController.viewControllers?[3] as? DineInVC {
            dineInVC.receivedItemCount = String(itemCount)
        }
    }
}
extension SelectionVC:UITableViewDataSource, UITableViewDelegate  {
    // MARK: - UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = data[indexPath.row]
            return cell
        }

        // MARK: - UITableViewDelegate

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Handle row selection, if needed
            print("Selected row: \(indexPath.row)")
        }
}
//MARK: Extension SearchBar
extension SelectionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    
    }
}
//MARK: Collection View
extension SelectionVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard segments.selectedSegmentIndex < sectionNames.count else {
            return 0
        }
        let selectedSectionID = sectionNameToID[sectionNames[segments.selectedSegmentIndex]] ?? -1
        let validItems = apiResponse.filter { item in
            return item.floorID == selectedSectionID && (item.tableNo != nil)
        }
        return validItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SelectionCVCell
        let selectedSectionIndex = segments.selectedSegmentIndex
        // Check if the selected segment index is within bounds
        if selectedSectionIndex >= 0 && selectedSectionIndex < sectionNames.count {
            let selectedSectionName = sectionNames[selectedSectionIndex]
            let selectedSectionID = sectionNameToID[selectedSectionName] ?? -1
            // Filter items based on the selected section's ID
            let sectionItems = apiResponse.filter { item in
                if let itemCategoryID = item.floorID {
                    return itemCategoryID == selectedSectionID
                }
                return false
            }
            // Check if indexPath.row is within bounds of sectionItems
            if indexPath.row < sectionItems.count {
                let item = sectionItems[indexPath.row]
                cell.tableNumberLbl?.text = item.tableNo
                print(item.tableID as Any)

            }
            if selectedIndexPaths.contains(indexPath) {
                cell.cellView.backgroundColor = #colorLiteral(red: 0.8596192002, green: 0.3426481783, blue: 0.2044148147, alpha: 1)
            } else {
                cell.cellView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedSegmentIndex = segments.selectedSegmentIndex
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectionCVCell {
            if let selectedText = cell.tableNumberLbl.text {
                let selectedSegmentTitle = segments.titleForSegment(at: segments.selectedSegmentIndex)
                let vc = self.tabBarController?.viewControllers?[3] as? DineInVC
                vc?.receivedLabelText = selectedText
                
                // Retrieve the item's tableID based on indexPath
                let selectedSectionIndex = segments.selectedSegmentIndex
                if selectedSectionIndex >= 0 && selectedSectionIndex < sectionNames.count {
                    let selectedSectionName = sectionNames[selectedSectionIndex]
                    let selectedSectionID = sectionNameToID[selectedSectionName] ?? -1
                    let sectionItems = apiResponse.filter { item in
                        if let itemCategoryID = item.floorID {
                            return itemCategoryID == selectedSectionID
                        }
                        return false
                    }
                    if indexPath.row < sectionItems.count {
                        let item = sectionItems[indexPath.row]
                        if let tableID = item.tableID {
                            var selectedTableIDs = UserDefaults.standard.string(forKey: "SelectedTableIDs") ?? ""
                            if !selectedTableIDs.isEmpty {
                                selectedTableIDs += ","
                            }
                            selectedTableIDs += "\(tableID)"
                            UserDefaults.standard.set(selectedTableIDs, forKey: "SelectedTableIDs")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
                if selectedIndexPaths.contains(indexPath) {
                    if let indexToRemove = selectedTableNumbers.firstIndex(of: selectedText) {
                        selectedTableNumbers.remove(at: indexToRemove)
                    }
                } else {
                    selectedTableNumbers.append(selectedText)
                }
                vc?.receivedSegmentTitle = selectedSegmentTitle
                vc?.receivedLabelText = selectedTableNumbers.joined(separator: " + ")
                vc?.receivedItemCount = String(itemCount)
            }
        }
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths.remove(indexPath)
        } else {
            selectedIndexPaths.insert(indexPath)
        }
        collectionView.reloadItems(at: [indexPath])
        if let tabBarController = self.tabBarController {
            let nextTabIndex = 3
            tabBarController.selectedIndex = nextTabIndex
        }
    }
}

//    func apiCalling(){
//        var sectionNameToID: [String: Int] = [:]
//        APIManager.makePOSTRequest { dashboardModelArray in
//            self.apiResponse = dashboardModelArray.flatMap { $0 }
//            let rowItemData = dashboardModelArray[1]
//            for dashboardModel in dashboardModelArray {
//                for row in dashboardModel {
//                        if let sectionID = row.floorID, let sectionName = row.floorName {
//                            if !sectionNameToID.keys.contains(sectionName) {
//                                sectionNameToID[sectionName] = sectionID
//                                print(sectionID)
//                                self.sectionNames.append(sectionName)
//                            }
//                        if let itemID = row.floorID {
//                            self.itemIDToSectionID[itemID] = sectionID
//                        }
//                    }
//                }
//            }
//            DispatchQueue.main.async {
//                self.apiResponse = rowItemData
//                self.segments.removeAllSegments()
//                self.sectionNameToID = sectionNameToID// Clear existing segments
//                for (index, sectionName) in self.sectionNames.enumerated() {
//                    self.segments.insertSegment(withTitle: sectionName, at: index, animated: false)
//                }
//                self.segments.selectedSegmentIndex = 0
//                self.collectionView.reloadData()
//            }
//        }
//    }
//func userDefaults() {
//    // Attempt to retrieve data from UserDefaults
//    if let savedData = UserDefaults.standard.data(forKey: "parsedDataKey") {
//        do {
//            // Decode the data into parsedRows
//            let decoder = JSONDecoder()
//            let parsedRows = try decoder.decode([[MasterDetailRow]].self, from: savedData)
//
//            // Process the parsed data
//            var sectionNameToID: [String: Int] = [:]
//            let rowItemData = parsedRows[1] // Assuming you want to use data from parsedRows
//            for dashboardModel in parsedRows {
//                for row in dashboardModel {
//                    if let sectionID = row.floorID, let sectionName = row.floorName {
//                        if !sectionNameToID.keys.contains(sectionName) {
//                            sectionNameToID[sectionName] = sectionID
//                            self.sectionNames.append(sectionName)
//                        }
//                        if let itemID = row.floorID {
//                            self.itemIDToSectionID[itemID] = sectionID
//                        }
//                    }
//                }
//            }
//            // UI updates on the main thread
//            DispatchQueue.main.async {
//                self.apiResponse = rowItemData
//                self.segments.removeAllSegments()
//                self.sectionNameToID = sectionNameToID // Clear existing segments
//                for (index, sectionName) in self.sectionNames.enumerated() {
//                    self.segments.insertSegment(withTitle: sectionName, at: index, animated: false)
//                }
//                self.segments.selectedSegmentIndex = 0
//                self.collectionView.reloadData()
//            }
//        } catch {
//            // Handle decoding errors
//            print("Error decoding saved data: \(error)")
//        }
//    } else {
//        // Handle the case where no data is saved in UserDefaults
//    }
//}






