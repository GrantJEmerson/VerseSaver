//
//  FirstViewController.swift
//  Bible Verse Saver
//
//  Created by Grant Emerson on 2/19/17.
//  Copyright © 2017 com.grant-emerson. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

// MARK: - Public Protocols

protocol LoadData {
    func reloadData()
}

class VerseListViewController: UIViewController, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    private var selectedBook = "Genesis"
    
    private let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private let constants = Constants.sharedInstance
    
    private let locationManager = CLLocationManager()
    private var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    private var verses: [Int] = {
        var verses = [Int]()
        verses += 1...176
        return verses
    }()
    
    private var chapters: [Int] = {
        var chapters = [Int]()
        chapters += 1...150
        return chapters
    }()
    
    private var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        return formatter
    }()
    
    private var textField: UITextField? {
        didSet {
            textField?.inputView = picker
            textField?.placeholder = "Verse..."
        }
    }
    
    private var picker = UIPickerView()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.dataSource = self
        
        if UserDefaults.isFirstLaunch() {
            let exampleVerse = Verse(context: moc)
            
            exampleVerse.date = Date()
            exampleVerse.verse = "John 3:16"
            exampleVerse.locationLatitude = 37.33182
            exampleVerse.locationLongitude = -122.0312
            exampleVerse.save()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Verse> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Verse> = Verse.fetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: "Master")
        fetchedResultsController.delegate = self
        _fetchedResultsController = fetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Verse>? = nil
    
    // Data Management Functions
    
    private func loadData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveVerse(verseLocation: String) {
        let verse = Verse(context: self.moc)
        verse.verse = verseLocation
        verse.date = Date()
        self.locationManager.requestLocation()
        verse.locationLatitude = self.location.coordinate.latitude
        verse.locationLongitude = self.location.coordinate.longitude
        verse.save()
    }
    
    // MARK: - IBActions
    
    @IBAction func addNewVerse(_ sender: UIBarButtonItem) {
        
        let addVereController = UIAlertController(title: "New Verse", message: "Add your new Bible Verse below.", preferredStyle: .alert)
        addVereController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        addVereController.addTextField { (verseTextField) in
            self.textField = verseTextField
        }
        addVereController.addAction(UIAlertAction(title: "Save", style: .default) { (alert) in
            
            guard let textField = addVereController.textFields?[0],
                let verses = self.fetchedResultsController.fetchedObjects else { return }
            
            let verseExists = verses.contains() { (verse) -> Bool in
                return verse.verse == textField.text
            }
            
            if !verseExists {
                guard let verse = textField.text else { return }
                self.saveVerse(verseLocation: verse)
                self.loadData()
                self.tableView.reloadData()
            }
        })
        self.present(addVereController, animated: true)
    }
    
    // MARK: - View Transition Functions
    
    private let transition = CircularTransition()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = view.center
        transition.circleColor = UIColor.white
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = view.center
        transition.circleColor = UIColor.darkGray
        
        return transition
    }
    
    // MARK: - LocationManagerDelegate Implementation
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[locations.count - 1]
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController, segue.identifier == "moreInfo" else { return }
        if let moreInfoVC = navController.viewControllers[0] as? MoreInfoViewController {
            navController.transitioningDelegate = self
            navController.modalPresentationStyle = .custom
            moreInfoVC.verse = sender as! Verse
            moreInfoVC.reloadDelegate = self
        }
    }
    
}

extension VerseListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView Delegate & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let verse = self.fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = verse.verse! + "\n" + formatter.string(from: verse.date!)
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        cell.layer.cornerRadius = 0.5 * cell.bounds.size.width
        cell.clipsToBounds = true
        
        switch (indexPath.row % 5) {
        case 0:
            cell.backgroundColor = constants.themeColors[0]
        case 1:
            cell.backgroundColor = constants.themeColors[1]
        case 2:
            cell.backgroundColor = constants.themeColors[2]
        case 3:
            cell.backgroundColor = constants.themeColors[3]
        case 4:
            cell.backgroundColor = constants.themeColors[4]
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let verse = self.fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "moreInfo", sender: verse)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        TipInCellAnimator.animate(cell: cell)
    }
}

extension VerseListViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Implementation of UIPickerViewDataSource and UIPickerViewDelegate for Verse Selector
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return constants.chaptersPerBook.count
        } else if component == 1 {
            if let chapters = constants.chaptersPerBook[selectedBook] {
                return chapters
            }
        }
        return 176 // For component 3 (verses)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return constants.books[row]
        } else if component == 1 {
            return String(chapters[row])
        }
        return String(verses[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let book = constants.books[picker.selectedRow(inComponent: 0)]
        let chapter = chapters[picker.selectedRow(inComponent: 1)]
        let verse = verses[picker.selectedRow(inComponent: 2)]
        textField?.text = "\(book) \(chapter):\(verse)"
        if (component == 0) {
            selectedBook = constants.books[row]
            pickerView.reloadComponent(1)
        }
    }
}

extension VerseListViewController: LoadData {
    
    // Custom LoadData Delegate Implentation
    
    func reloadData() {
        loadData()
        tableView.reloadData()
    }
}
