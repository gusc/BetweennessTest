//
//  StartViewController.swift
//  VRBoilerplate
//
//  Created by Gusts Kaksis on 30/12/2018.
//  Copyright © 2018 Andrian Budantsov. All rights reserved.
//

import Foundation

extension UIViewController {
    func performBackSegue()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            if let pp = self.presentedViewController {
                pp.dismiss(animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

class StartViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var selectedLanguage = 0
    var selectedLanguageNext = 0
    var languages: [String] = [ "Latvian", "Russian", "English", "Other" ]
    var selectedPlace = 0
    var selectedPlaceNext = 0
    var places: [String] = [ "City", "Town", "Country side" ]
    var hobbies: [String] = [ "Grāmatas, žurnāli, u.c. lasīšana",
                              "Tūrisms, ceļošana",
                              "Mācīšanās, zināšanu papildināšana, kursi",
                              "Datorspēles, videospēles",
                              "Citas ar IT un/vai datoru saistītas nodarbes (sociālie tīkli, blogi, u.c.)",
                              "Sportošana",
                              "Sporat pasākumu vērošana",
                              "Dejas u.c., kustību aktivitātes",
                              "Dziedāšana, muzicēšana",
                              "Mūzikas klausīšanās",
                              "Kultūras pasākumu apmeklēšana (teātris, koncerti, izstādes)",
                              "Kino skatīšanās",
                              "Fotografēšana",
                              "Zīmēšana u.c. vizuālā māksla",
                              "Amatniecība (šūšana, adīšana, kokapstrāde utml.)",
                              "Darbošanās ar tehniku (auto, radio utml.)",
                              "Dārza, lauku darbi (puķkopība, sēņošana, ogošana, utml.)",
                              "Mājas labiekārtošana",
                              "Mēdības, makšķerēšana",
                              "Kulinārija, ēst gatavošana",
                              "Kolekcionēšana",
                              "Cits"]
    var selectedHobbies: [Bool] = [ ]
    
    var languagePicker:UIPickerView!
    var placePicker:UIPickerView!
    
    @IBOutlet weak var genderSelector: UISegmentedControl!
    @IBOutlet weak var ageSpinner: UIStepper!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var handednessSelector: UISegmentedControl!
    
    @IBAction func ageUpdate(_ sender: Any) {
        ageLabel.text = String(Int(ageSpinner.value))
    }
    
    @IBOutlet weak var languageInput: UITextField!
    @IBOutlet weak var homeCityInput: UITextField!
    @IBOutlet weak var homeCityTypeInput: UITextField!
    @IBOutlet weak var hobbyTable: UITableView!
    
    @IBAction func startTest(_ sender: Any) {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        app.store(name: "Gender", value: genderSelector.titleForSegment(at: genderSelector.selectedSegmentIndex)!)
        app.store(name: "Age", value: String(Int(ageSpinner.value)))
        app.store(name: "Handedness", value: handednessSelector.titleForSegment(at: handednessSelector.selectedSegmentIndex)!)
        app.store(name: "Language", value: self.languages[self.selectedLanguage])
        app.store(name: "Hometown", value: homeCityInput.text!)
        app.store(name: "Type", value: self.places[self.selectedPlace])
        
        var hobbyStr = ""
        for i in 0...hobbies.count - 1 {
            if selectedHobbies[i] {
                hobbyStr += hobbies[i] + ", "
            }
        }
        app.store(name: "Hobbies", value: hobbyStr)
    }
    
    //
    // Languages or places picker
    //
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.languagePicker {
            return languages.count
        } else {
            return places.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.languagePicker {
            return languages[row]
        } else {
            return places[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.languagePicker {
            self.selectedLanguageNext = row
        } else {
            self.selectedPlaceNext = row
        }
    }
    
    //
    // Hobby table
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hobbies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hobbyCell", for: indexPath)
        cell.textLabel?.text = hobbies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedHobbies[indexPath.row] = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedHobbies[indexPath.row] = false
    }
    
    @objc
    func donePicker() {
        self.selectedLanguage = self.selectedLanguageNext;
        self.selectedPlace = self.selectedPlaceNext;
        self.closePicker()
    }
    
    @objc
    func closePicker() {
        self.selectedLanguageNext = self.selectedLanguage
        self.selectedPlaceNext = self.selectedPlace
        self.languageInput.text = languages[self.selectedLanguage]
        self.homeCityTypeInput.text = places[self.selectedPlace]
        self.languageInput.resignFirstResponder()
        self.homeCityTypeInput.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedHobbies = Array(repeating: false, count: self.hobbies.count)
        
        self.languageInput.text = languages[self.selectedLanguage]
        self.homeCityTypeInput.text = places[self.selectedPlace]
        
        self.languagePicker = UIPickerView()
        self.languagePicker.backgroundColor = .white
        self.languagePicker.showsSelectionIndicator = true
        self.languagePicker.delegate = self
        self.languagePicker.dataSource = self
        
        self.placePicker = UIPickerView()
        self.placePicker.backgroundColor = .white
        self.placePicker.showsSelectionIndicator = true
        self.placePicker.delegate = self
        self.placePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StartViewController.donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(StartViewController.closePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.languageInput.inputView = self.languagePicker;
        self.languageInput.inputAccessoryView = toolBar;
        self.homeCityTypeInput.inputView = self.placePicker;
        self.homeCityTypeInput.inputAccessoryView = toolBar;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.openFile()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
    }
    
}
