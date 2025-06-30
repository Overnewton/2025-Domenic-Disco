import UIKit
import Foundation

struct ContentManager {
    var currentOptions: [(identifier: Int, title: String, type: Int)]
    var currentDisplay: String
    var savedTextfieldInformation: [String]
    var savedInteger: Int
    var savedDropdownInformation: Int
    var displaySeperate: [String]
    var repeatedString: String
    var returnPoint: Int
    var exitString: String
    var storedDropdowns: [String]
    var savedText: [String]
    var selectedPlayer: String
    var selectedActivity: Int
    var tableValues: [(title: String, value: String)]
    var selectedDropdownIndex: Int
    var selectedRow: Int
}

var contentManager: ContentManager = ContentManager(currentOptions: [(-20, "Begin Program", 1)], currentDisplay: "", savedTextfieldInformation: [], savedInteger: 0, savedDropdownInformation: 0, displaySeperate: [], repeatedString: "", returnPoint: 0, exitString: "", storedDropdowns: [], savedText: [], selectedPlayer: "", selectedActivity: 0, tableValues: [], selectedDropdownIndex: 0, selectedRow: 0)

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var textFields: [UITextField] = []
    var dropdowns: [UIPickerView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runUpdates(UIButton())
        print(directoryURL)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        runCheck(sender)
        for view in view.subviews {
            view.removeFromSuperview()
        }
        runUpdates(sender)
    }
    
    func runCheck(_ sender: UIButton) {
        saveTextFieldData()
        contentManager.currentOptions = []
        switch sender.tag {
        case -20:
            user.details.username = ""
            if existingFiles() {
                contentManager.currentDisplay = "Save data has been detected on this device, would you like to load from one of the accounts, or create a new one?"
                contentManager.currentOptions = []
                for (password,username) in getPasswords() {
                    contentManager.currentOptions.append((-19,"Load \(username)",1))
                }
                contentManager.currentOptions.append((-16,"Create New Account",1))
            } else {
                contentManager.currentDisplay = "Hello! Please create an account so that you can use this application!"
                contentManager.currentOptions = [(-16,"Create An Account",1)]
            }
        case -19: // Loading Data
            // Get the players username
            var sendString: String = sender.titleLabel!.text!
            sendString.removeFirst(5)
            sendString = sendString.components(separatedBy: " ")[0]
            
            for (password,username) in getPasswords() {
                if username == sendString {
                    contentManager.currentDisplay = "This account requires a password to log in, would you like to access it?"
                    user.details.username = sendString
                    contentManager.currentOptions = [(-18,"Yes",1),(-20,"No",1)]
                    break
                }
            }
        case -18:
            contentManager.currentDisplay = "Please enter the password"
            contentManager.currentOptions = [(0,"Password",2),(-17,"Input Data",1),(-20,"Exit Menu",1)]
        case -17:
            for (password,username) in getPasswords() {
                if username == user.details.username {
                    if password == contentManager.savedTextfieldInformation[0] {
                        contentManager.currentDisplay = "That password is correct, the save data for account \(user.details.username) has been loaded. Please enjoy using the application!"
                        loadGameData()
                        contentManager.currentOptions = [(0,"Begin Using The Program",1)]
                        break
                    } else {
                        contentManager.currentDisplay = "Incorrect Password, try again."
                        contentManager.currentOptions = [(0,"Password",2),(-17,"Input Data",1),(-20,"Exit Menu",1)]
                        break
                    }
                }
            }
        case -16:
            contentManager.currentDisplay = "Please input your details"
            contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Input Data",1)]
        case -15: // Create Private Account Confirmation
            if acceptableAccount(input: contentManager.savedTextfieldInformation) {
                if contentManager.savedTextfieldInformation[1].localizedStandardContains("-") {
                    contentManager.currentDisplay = "Unfortunately my program doesn't allow for '-' to be placed within usernames or passwords, I'm very sorry for the inconvenience but please change your input."
                    contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1)]
                } else {
                    if contentManager.savedTextfieldInformation.contains("") {
                        contentManager.currentDisplay = "Unfortunately my program doesn't allow for ' ' to be used as usernames or passwords, I'm very sorry for the inconvenience but please change your input."
                        contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1)]
                    } else {
                        user.details.password = contentManager.savedTextfieldInformation[0]
                        user.details.username = contentManager.savedTextfieldInformation[1]
                        addPassword()
                        contentManager.currentDisplay = "Congratulations, your account \(user.details.username) has been created!"
                        contentManager.currentOptions = [(-14,"Begin Application Tutorial",1)]
                    }
                }
            } else {
                contentManager.currentDisplay = "Unfortunately that username is already in use, please select a different one"
                contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1)]
            }
        case -14:
            contentManager.currentDisplay = "Hello my dear user, I'm Domenic Disco, the creator of this application that you are using.\n\nI'm assuming that you know what the app is about, but if you don't, it's a method of storing players and sorting for a given activity of any type"
            contentManager.currentOptions = [(-13,"Next",1)]
        case -13:
            contentManager.currentDisplay = "You could store any kind of activity, maybe board game statistics, league of legends, mario kart race times, basketball player statistics. You could even go as far as storing student grades within this application, since it's perfect for storing and sorting any kind of statistics for a group or collection of people"
            contentManager.currentOptions = [(-12,"Next",1)]
        case -12:
            contentManager.currentDisplay = "Now, how do you use my application?\n\nFirst, you create an activity. This will be done in a 3 step procedure.\n\n1 - Add the activity name, just input it into a text field and press a button to confirm\n\n2 - Add the activities statistics, type the statistic name into a text field, select it's type in a dropdown menu, and then press a button to add it\n\n3 - Add any base values for statistics, you select a statistic using a dropdown menu, and then input the basic value into the text field below.\n\nAnd that's all it takes, just do those 3 steps and you'll have an activity!"
            contentManager.currentOptions = [(-11,"Next",1)]
        case -11:
            contentManager.currentDisplay = "But just having an activity isn't enough, you need to have some players otherwise there's not much point to the application. To make players, you follow another easy 3 step procedure\n\n1 - Add the players name, once again in a text field\n\n2 - Set the players statistics using the same method as setting basic statistics for an activity\n\n3 - Then you can decide if you want the player to be part of a team or group, allowing them to be more easily sorted.\n\nAnd that's all it needs, just 3 easy steps and you can fill up your activity with any player you'd need!"
            contentManager.currentOptions = [(-10,"Next",1)]
        case -10:
            contentManager.currentDisplay = "And that's all you'll need to use my program! There are some complicated features later on, such as my complicated sorting and searching algorithms, but those will be covered when you get to them. No reason to overcomplicate you experience right now.\n\nGood luck with your storing and managing of activities!"
            contentManager.currentOptions = [(0,"Begin The Program",1)]
        case -9: break
        case -8: break
        case -7: break
        case -6: break
        case -5: break
        case -4: break
        case -3: break
        case -2: break
        case -1:
            if contentManager.displaySeperate.count > 1 {
                contentManager.currentDisplay = contentManager.displaySeperate.first!
                contentManager.displaySeperate.removeFirst()
                contentManager.currentOptions = [(-1, "\(contentManager.repeatedString)", 1)]
            } else {
                contentManager.currentOptions = [(contentManager.returnPoint, "\(contentManager.exitString)", 1)]
            }
        case 0: // Main Screen
            contentManager.currentDisplay = "Hello \(user.details.username), what do you want to do?"
            contentManager.currentOptions = [(1,"View Activities",1),(0,"Modify System Settings",1),(0,"Log Out",1)]
        case 1:
            if user.activities.isEmpty {
                contentManager.currentDisplay = "What would you like to do"
                contentManager.currentOptions = [(2,"Create New Activity",1),(0,"Exit",1)]
            } else {
                contentManager.currentDisplay = "Please select the activity that you want to view using the dropdown menu. Or press 'Create New Activity' to create a new activity."
                contentManager.currentOptions = [(0,"Activity",7),(2,"View Activity",1),(2,"Create New Activity",1)]
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for activity in user.activities {
                    contentManager.tableValues.append((activity.name,""))
                    contentManager.storedDropdowns.append(activity.name)
                }
            }
        case 2:
            contentManager.currentDisplay = "You have decided to create a new activity, what would you like it's name to be?"
            contentManager.currentOptions = [(0,"Activity Name", 2),(3,"Create Activity",1), (1,"Exit Menu",1)]
        case 3:
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give an activity the name of ''. That would just not work with the rest of my code. Please give it an actual name"
                contentManager.currentOptions = [(2,"Exit",1)]
            } else {
                var dupeName: Bool = false
                for activity in user.activities {
                    if activity.name == contentManager.savedTextfieldInformation[0] {
                        dupeName = true
                    }
                }
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give an activity a name that's already been used. Please give it a different name"
                    contentManager.currentOptions = [(2,"Exit",1)]
                } else {
                    contentManager.savedText.append(contentManager.savedTextfieldInformation[0])
                    contentManager.currentDisplay = "Please input the statistics that will be used for activity \(contentManager.savedTextfieldInformation[0]).\n\nTo do this, write down the statistic name in the text field, and then exit the text field to add it to the table."
                    contentManager.currentOptions = [(0,"Statistic",8),(4,"Finalise Statistics",1),(1,"Exit Menu",1)]
                    contentManager.tableValues = [("Placeholder","")]
                }
            }
        case 4:
            contentManager.currentDisplay = "Please add any basic statistics to this activity, such as points scores starting at 0, or whatever initial values you want to use."
            contentManager.currentOptions = [(0,"Statistic",6),(5,"Finalise Activity",1),(1,"Exit Menu",1)]
        case 5:
            contentManager.currentDisplay = "Congratulations, you have successfully created the activity \(contentManager.savedTextfieldInformation[0]). This activity has \(contentManager.tableValues.count) statistics being tracked!"
            // Create Activity Here
            var newActivity: Activity = Activity(name: contentManager.savedTextfieldInformation[0], people: [:], combined: StatisticHolder(statistics: []), overallStatistics: [])
            for (title,value) in contentManager.tableValues {
                newActivity.overallStatistics.append(Statistic(name: title, value: Int(value)!, rule: []))
            }
            
            contentManager.currentOptions = [(1,"Exit Menu",1)]
        case 6:
            contentManager.currentDisplay = ""
            contentManager.currentOptions = []
        case 7:
            contentManager.currentDisplay = ""
            contentManager.currentOptions = []
        case 8:
            contentManager.currentDisplay = ""
            contentManager.currentOptions = []
        case 9:
            contentManager.currentDisplay = ""
            contentManager.currentOptions = []
        case 10:
            contentManager.currentDisplay = ""
            contentManager.currentOptions = []
        case 11: break
        case 12: break
        case 13: break
        case 14: break
        case 15: break
        case 16: break
        case 17: break
        case 18: break
        case 19: break
        case 20: break
        case 21: break
        case 22: break
        case 23: break
        case 24: break
        case 25: break
        case 26: break
        case 27: break
        case 28: break
        case 29: break
        case 30: break
        case 31: break
        case 32: break
        case 33: break
        case 34: break
        case 35: break
        case 36: break
        case 37: break
        case 38: break
        case 39: break
        case 40: break
        case 41: break
        case 42: break
        case 43: break
        case 44: break
        case 45: break
        case 46: break
        case 47: break
        case 48: break
        case 49: break
        case 50: break
        case 51: break
        case 52: break
        case 53: break
        case 54: break
        case 55: break
        case 56: break
        case 57: break
        case 58: break
        case 59: break
        case 60: break
        case 61: break
        case 62: break
        case 63: break
        case 64: break
        case 65: break
        case 66: break
        case 67: break
        case 68: break
        case 69: break
        default: break
        }
    }
    
    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = []
        
        for number in 0...9 {
            let input = "\(number)"  // Convert number to string
            let command = UIKeyCommand(input: input, modifierFlags: [], action: #selector(numberKeyPressed(_:)))
            commands.append(command)
        }
        
        let upArrowCommand = UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(upArrowPressed(_:)))
        let downArrowCommand = UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(downArrowPressed(_:)))
        let leftArrowCommand = UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(leftArrowPressed(_:)))
        let rightArrowCommand = UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(rightArrowPressed(_:)))
        
        commands.append(upArrowCommand)
        commands.append(downArrowCommand)
        commands.append(leftArrowCommand)
        commands.append(rightArrowCommand)
        
        return commands
    }
    
    @objc func numberKeyPressed(_ sender: UIKeyCommand) {
        guard let input = sender.input, let index = Int(input) else { return }  // Convert input to Int
        
        // Check if we have an option at the button input
        if contentManager.currentOptions.indices.contains(index - 1) {
            // If we do, then check that it's a button
            if contentManager.currentOptions[index - 1].type == 1 {
                // If it is then forcibly run a clone of that button
                let option = contentManager.currentOptions[index - 1]
                let buttonInput: UIButton = UIButton()
                buttonInput.tag = option.identifier
                buttonInput.setTitle(option.title, for: .normal)
                buttonPressed(buttonInput)
            }
        } else {
            print("Invalid option index: \(index - 1)")
        }
    }
    
    @objc func upArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "↑", contentManager.currentOptions[value].type))
        }
    }
    @objc func downArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "↓", contentManager.currentOptions[value].type))
        }
    }
    @objc func leftArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "←", contentManager.currentOptions[value].type))
        }
    }
    @objc func rightArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "→", contentManager.currentOptions[value].type))
        }
    }
    
    func runFakeButton(_ input: (Int,String,Int)) {
        let buttonInput: UIButton = UIButton()
        buttonInput.tag = input.0
        buttonInput.setTitle(input.1, for: .normal)
        buttonPressed(buttonInput)
    }
    
    func checkArrows() -> Int {
        for (index,(_,_,value)) in contentManager.currentOptions.enumerated() {
            if value == 4 {
                return index
            }
        }
        return -1
    }
    
    func saveTextFieldData() {
        contentManager.savedTextfieldInformation.removeAll()
        for textField in textFields {
            contentManager.savedTextfieldInformation.append(textField.text ?? "")
        }
        textFields.removeAll()
    }
    
    func runUpdates(_ sender: UIButton) {
        var yOffset: CGFloat = 60
        
        // Sets the displayed text at the top of the page as a UILabel
        let displayLabel = UILabel()
        displayLabel.text = contentManager.currentDisplay
        contentManager.currentDisplay = ""
        displayLabel.numberOfLines = 0
        displayLabel.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 20, height: 0)
        displayLabel.sizeToFit()
        view.addSubview(displayLabel)
        if displayLabel.text != "" {
            yOffset += displayLabel.frame.height + 10
        }
        
        var index: Int = 0
        // Then uses each stored option in contentManager.currentOptions to create elements
        for (identifier, title, type) in contentManager.currentOptions {
            switch type {
            case 1:
                // Creates buttons
                let button = createButton(with: title, action: #selector(buttonPressed(_:)), color: .systemBlue)
                button.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                button.tag = identifier
                view.addSubview(button)
                if index < 9 && title != "" {
                    let label = UILabel()
                    label.textColor = .systemBlue
                    label.layer.position.x = 370
                    label.layer.position.y = yOffset + 10
                    label.font = UIFont.systemFont(ofSize: 15) // Adjust font size as needed
                    label.text = "[\(index + 1)]"
                    index += 1
                    label.sizeToFit() // Resize label based on content
                    
                    view.addSubview(label)
                }
                
                yOffset += 50
            case 2:
                // Creates text fields
                let label = UILabel()
                label.text = "Enter \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 30
                
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 40)
                view.addSubview(textField)
                textFields.append(textField)
                yOffset += 50
            case 3:
                // Creates dropdown menus
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 10
                
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                view.addSubview(dropdown)
                dropdowns.append(dropdown)
                yOffset += 160
            case 4:
                // Creates arrow things
                let list: [String] = ["←","↓","→","↑"]
                var xOffset: Int = 20
                for index in 0...2 {
                    let button = createButton(with: list[index], action: #selector(buttonPressed(_:)), color: .systemBlue)
                    if index % 2 == 0 {
                        button.frame = CGRect(x: xOffset, y: Int(yOffset) - 15, width: 30, height: 40)
                    } else {
                        button.frame = CGRect(x: xOffset, y: Int(yOffset), width: 30, height: 40)
                    }
                    button.tag = sender.tag
                    view.addSubview(button)
                    xOffset += 20
                }
                yOffset -= 30
                let button = createButton(with: list[3], action: #selector(buttonPressed(_:)), color: .systemBlue)
                button.frame = CGRect(x: xOffset - 40, y: Int(yOffset), width: 30, height: 40)
                button.tag = sender.tag
                view.addSubview(button)
                
                yOffset += 60
            case 5:
                // Creates action dropdown menus
                // Creates the selection label
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 10
                
                // Create the dropdown menu
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                view.addSubview(dropdown)
                dropdowns.append(dropdown)
                yOffset += 10
            
                // Creates the display label below
                let subLabel = UILabel()
                subLabel.numberOfLines = 0
                // Ensure the subLabel can hold that many characters in size
                subLabel.text = "__________________________________________________________________________________________________________________________________________________"
                subLabel.frame = CGRect(x: 10, y: yOffset + 160, width: view.frame.width - 40, height: 20)
                subLabel.sizeToFit()
                view.addSubview(subLabel)
                yOffset += (subLabel.frame.height + 10)
                
                yOffset += 200
                
                // Initialise the subLabel
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
            case 6:
                // Table View
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                view.addSubview(tableView)
                yOffset += 160
                
                // Picker label
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 30

                // Picker
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 100)
                dropdown.tag = dropdowns.count // to identify in delegate
                view.addSubview(dropdown)
                dropdowns.append(dropdown)
                yOffset += 110

                // Text Field
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                textField.text = getSelectedValue()
                textField.addTarget(self, action: #selector(updateTableValue(_:)), for: .editingDidEnd)
                textFields.append(textField)
                view.addSubview(textField)
                yOffset += 50

                // Refresh selection state
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
            case 7:
                // Table View
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                view.addSubview(tableView)
                yOffset += 160
                
                // Picker label
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 30

                // Picker
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 100)
                dropdown.tag = dropdowns.count // to identify in delegate
                view.addSubview(dropdown)
                dropdowns.append(dropdown)
                yOffset += 110

                // Refresh selection state
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
            case 8:
                // Table View
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                view.addSubview(tableView)
                yOffset += 160

                // Text Field
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                textField.text = ""
                textFields.append(textField)
                view.addSubview(textField)
                yOffset += 50
                
                // Creates buttons
                let button = createButton(with: "Add \(title)", action: #selector(addTableValues(_:)), color: .systemBlue)
                button.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                button.tag = identifier
                view.addSubview(button)
                if index < 9 && title != "" {
                    let label = UILabel()
                    label.textColor = .systemBlue
                    label.layer.position.x = 370
                    label.layer.position.y = yOffset + 10
                    label.font = UIFont.systemFont(ofSize: 15) // Adjust font size as needed
                    label.text = "[\(index + 1)]"
                    index += 1
                    label.sizeToFit() // Resize label based on content
                    
                    view.addSubview(label)
                }
                yOffset += 50
                
                // Creates buttons
                let button2 = createButton(with: "Remove \(title)", action: #selector(removeTableValues(_:)), color: .systemBlue)
                button2.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                button2.tag = identifier
                view.addSubview(button2)
                if index < 9 && title != "" {
                    let label = UILabel()
                    label.textColor = .systemBlue
                    label.layer.position.x = 370
                    label.layer.position.y = yOffset + 10
                    label.font = UIFont.systemFont(ofSize: 15) // Adjust font size as needed
                    label.text = "[\(index + 1)]"
                    index += 1
                    label.sizeToFit() // Resize label based on content
                    
                    view.addSubview(label)
                }
                yOffset += 50
            default:
                break
            }
        }
    }
    
    func getSelectedValue() -> String {
        let statIndex = contentManager.selectedDropdownIndex
        return contentManager.tableValues[statIndex].value
    }
    
    func createButton(with title: String, action: Selector, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.5)
        return button
    }

    // MARK: - PickerView DataSource & Delegate

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Dropdown shows titles from tableValues
        return contentManager.tableValues.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Just the title of the tableValue at that row
        guard row < contentManager.tableValues.count else { return nil }
        return contentManager.tableValues[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < contentManager.tableValues.count else { return }
        contentManager.selectedDropdownIndex = row
        updateTextFieldWithSelectedValue()
    }

    // MARK: - TextField Updates

    func updateTextFieldWithSelectedValue() {
        let index = contentManager.selectedDropdownIndex
        guard index < contentManager.tableValues.count else { return }
        
        let selectedValue = contentManager.tableValues[index].value
        
        // Find the first UITextField in the view (assuming there's only one relevant one)
        for subview in view.subviews {
            if let tf = subview as? UITextField {
                tf.text = selectedValue
                // Add target only once to avoid duplicates if needed
                if tf.allTargets.isEmpty {
                    tf.addTarget(self, action: #selector(updateTableValue(_:)), for: .editingChanged)
                }
                break
            }
        }
    }

    @objc func updateTableValue(_ sender: UITextField) {
        let index = contentManager.selectedDropdownIndex
        guard index < contentManager.tableValues.count,
              let newText = sender.text else { return }
        
        // Update the value in the tuple while preserving title and type
        let (title, value) = contentManager.tableValues[index]
        contentManager.tableValues[index] = (title, newText)
        
        // Reload the table view to reflect changes
        if let tableView = view.viewWithTag(999) as? UITableView {
            tableView.reloadData()
        }
    }
    
    @objc func addTableValues(_ sender: UIButton) {
        let text = view.subviews[2] as! UITextField
        let table = view.subviews[1] as! UITableView
        if text.text! != "" {
            if contentManager.tableValues.isEmpty {
                contentManager.tableValues = [(title: text.text!, value: "")]
            } else if contentManager.tableValues[0] == ("Placeholder","") {
                contentManager.tableValues = [(title: text.text!, value: "")]
            } else {
                contentManager.tableValues.append((title: text.text!, value: ""))
            }
            table.reloadData()
        }
    }
    
    @objc func removeTableValues(_ sender: UIButton) {
        if contentManager.tableValues.count >= 1 {
            let table = view.subviews[1] as! UITableView
            contentManager.tableValues.removeLast()
            table.reloadData()
        }
    }

    // MARK: - TableView DataSource & Delegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentManager.tableValues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let item = contentManager.tableValues[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.value
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < contentManager.tableValues.count else { return }
        
        contentManager.selectedDropdownIndex = indexPath.row
        updateTextFieldWithSelectedValue()
    }

    func generateUpdates(person: Person) {
        contentManager.currentOptions.append((identifier: 0, title: "Stat to Edit", type: 6))
        contentManager.storedDropdowns = []
        contentManager.tableValues = []
        contentManager.selectedDropdownIndex = 0
        contentManager.selectedRow = 0
    }
}
