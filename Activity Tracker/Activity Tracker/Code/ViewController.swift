import UIKit
import Foundation

// Class used to store values within the application,
struct ContentManager {
    // Values used to display UI Elements to the user
    var currentOptions: [(identifier: Int, title: String, type: Int)]
    
    // Value used to display a text element to the user
    var currentDisplay: String
    
    // Permanent storage of values
    var savedTextfieldInformation: [String]
    var savedIntegers: [Int]
    var savedDropdownInformation: Int
    
    // Values used to display elements one by one
    var displaySeperate: [String]
    var repeatedString: String
    var returnPoint: Int
    var exitString: String
    
    // Values used to store values for a long time
    var storedDropdowns: [String]
    var savedText: [String]
    var selectedValues: StoredActivity
    
    // Values used to generate a table view
    var tableValues: [(title: String, value: String)]
    
    // Values storing the users selection within dropdowns
    var selectedDropdownIndex: Int
    var selectedRow: Int
}

// A struct that stores the users selection of activity, team, group and player as an Int for later use
struct StoredActivity {
    var activity: Int
    var team: Int
    var group: Int
    var player: Int
}

// Initialises the content manager for use throughout the code
var contentManager: ContentManager = ContentManager(currentOptions: [(-20, "Begin Program", 1)], currentDisplay: "", savedTextfieldInformation: [], savedIntegers: [], savedDropdownInformation: 0, displaySeperate: [], repeatedString: "", returnPoint: 0, exitString: "", storedDropdowns: [], savedText: [], selectedValues: StoredActivity(activity: -1, team: -1, group: -1, player: -1), tableValues: [], selectedDropdownIndex: 0, selectedRow: 0)

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // Storage of text fields and dropdowns that are generated
    var textFields: [UITextField] = []
    var dropdowns: [UIPickerView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run a fake button input to initialise the screen
        runUpdates(UIButton())
        
        // Prints out the directory URL incase I forget it
        print(directoryURL)
    }
    
    // Runs when the user presses a button on screen
    @objc func buttonPressed(_ sender: UIButton) {
        // Checks what button it was and runs code accordingly
        runCheck(sender)
        
        // Clears the screen
        for view in view.subviews {
            view.removeFromSuperview()
        }
        
        // Updates the screen with new UI Elements
        runUpdates(sender)
    }
    
    // Function to handle all logic regarding what to display on the screen
    func runCheck(_ sender: UIButton) {
        
        // Save all values that the user has input
        saveTextFieldData()
        saveDropdownData()
        
        // Ensure that the elements to display have been cleared
        contentManager.currentOptions = []
        
        // Figure out which button the user pressed, and run the code for that button
        switch sender.tag {
        case -20: // Initial Login -> Ran upon the aplication starting
            user.details.username = ""
            
            // Checks if save files exist on the device
            if existingFiles() {
                
                contentManager.currentDisplay = "Save data has been detected on this device, would you like to load from one of the accounts, or create a new one?"
                contentManager.currentOptions = []
                
                // For each account that is saved, display it as a button
                for (_,username) in getPasswords() {
                    contentManager.currentOptions.append((-19,"Load \(username)",1))
                }
                
                // Or let them make a new account
                contentManager.currentOptions.append((-16,"Create New Account",1))
            } else {
                // If no save files exist then the user must make a new account
                contentManager.currentDisplay = "Hello! Please create an account so that you can use this application!"
                
                // Create a button for account creation
                contentManager.currentOptions = [(-16,"Create An Account",1)]
            }
            
        case -19: // Loading Data -> Prepares the user to login to the program
            
            // Get the account that they selected through it's titleLabel
            var sendString: String = sender.titleLabel!.text!
            
            // Remove the "Load " from the string
            sendString.removeFirst(5)
            
            // This is here just incase my code suddenly breaks for me to have some backup
            // sendString = sendString.components(separatedBy: " ")[0]
            
            // Run through all the saved accounts
            for (_,username) in getPasswords() {
                if username == sendString {
                    contentManager.currentDisplay = "This account requires a password to log in, would you like to access it?"
                    user.details.username = sendString
                    
                    // Create buttons for Yes and No
                    contentManager.currentOptions = [(-18,"Yes",1),(-20,"No",1)]
                    break
                }
            }
            
        case -18: // Password Entry -> Has the user login to the program by inputting the password
            contentManager.currentDisplay = "Please enter the password"
            
            // Create a text field for password input, a button for input data and another button to exit the page
            contentManager.currentOptions = [(0,"Password",2),(-17,"Input Data",1),(-20,"Exit Menu",1)]
            
        case -17: // Password Confirmation -> Checks if input matches
            var acceptedLogin: Bool = false
            
            // Run through all the accounts
            for (password,username) in getPasswords() {
                
                // Check username and password are correct
                if username == user.details.username {
                    if password == contentManager.savedTextfieldInformation[0] {
                        
                        // Let the user login
                        contentManager.currentDisplay = "That password is correct, the save data for account \(user.details.username) has been loaded. Please enjoy using the application!"
                        
                        // Get the app ready to start
                        clearTextFieldData()
                        loadGameData()
                        
                        // Create a button for starting the program
                        contentManager.currentOptions = [(0,"Begin Using The Program",1)]
                        acceptedLogin = true
                        break
                    }
                }
            }
            
            // If the code didn't manage to run then make them retry
            if !acceptedLogin {
                contentManager.currentDisplay = "Incorrect Password, try again."
                clearTextFieldData()
                
                // Create a text field for password input, a button to input data and a button to exit the page
                contentManager.currentOptions = [(0,"Password",2),(-17,"Input Data",1),(-20,"Exit Menu",1)]
            }
            
        case -16: // Account Creation -> Have the user input a username/password for new account
            contentManager.currentDisplay = "Please input your details"
            
            // Create a text field for password input, a text field for username input and a button to input data
            contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Input Data",1)]
            clearTextFieldData()
            
        case -15: // Create Account Confirmation
            
            // Check if the users username and password work with the program
            if acceptableAccount(input: contentManager.savedTextfieldInformation) {
                
                // Check if they contain "-" cause my CSV file stores the accounts as "Username-Password", so if they had "-" it would break my code
                if contentManager.savedTextfieldInformation[1].localizedStandardContains("-") {
                    contentManager.currentDisplay = "Unfortunately my program doesn't allow for \"-\" to be placed within usernames or passwords, I'm very sorry for the inconvenience but please change your input."
                    
                    // Create a text field for password input, a text field for username input, a button to input data and a button to exit the page
                    contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1),(-20,"Exit Menu",1)]
                    clearTextFieldData()
                } else {
                    
                    // Make sure that neither the username or the password are blank since that might also break my code. Not sure if it would, but I just don't want to deal with it
                    if contentManager.savedTextfieldInformation.contains("") {
                        contentManager.currentDisplay = "Unfortunately my program doesn't allow for \" \" to be used as usernames or passwords, I'm very sorry for the inconvenience but please change your input."
                        
                        // Create a text field for password input, a text field for username input, a button to input data and a button to exit the page
                        contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1), (-20,"Exit Menu",1)]
                        clearTextFieldData()
                        
                        // If it passes all the checks, then let them create the account
                    } else {
                        // Set the users details
                        user.details.password = contentManager.savedTextfieldInformation[0]
                        user.details.username = contentManager.savedTextfieldInformation[1]
                        
                        clearTextFieldData()
                        
                        // Add the account to the save file
                        addPassword()
                        
                        contentManager.currentDisplay = "Congratulations, your account \(user.details.username) has been created!"
                        
                        // Create a button to begin the application
                        contentManager.currentOptions = [(-14,"Begin Application Tutorial",1)]
                    }
                }
                
                // Check if the username is already in use cause I also can't be bothered to handle two accounts with the same username but different passwords
            } else {
                contentManager.currentDisplay = "Unfortunately that username is already in use, please select a different one"
                
                // Create a text field for password input, a text field for username input, and a button to input data
                contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1)]
                clearTextFieldData()
            }
            
        case -14: // Tutorial Text 1 -> Text explaining how to use my app
            contentManager.currentDisplay = "Hello my dear user, I'm Domenic Disco, the creator of this application that you are using.\n\nI'm assuming that you know what the app is about, but if you don't, it's a method of storing players and sorting for a given activity of any type"
            
            // Create a button to go to next page, and one to skip the tutorial
            contentManager.currentOptions = [(-13,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -13: // Tutorial Text 2 -> Text explaining how to use my app
            contentManager.currentDisplay = "You could store any kind of activity, maybe board game statistics, league of legends, mario kart race times, basketball player statistics. You could even go as far as storing student grades within this application, since it's perfect for storing and sorting any kind of statistics for a group or collection of people"
            
            // Create a button to go to next page, and one to skip the tutorial
            contentManager.currentOptions = [(-12,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -12: // Tutorial Text 3 -> Text explaining how to use my app
            contentManager.currentDisplay = "Now, how do you use my application?\n\nFirst, you create an activity. This will be done in a 3 step procedure.\n\n1 - Add the activity name, just input it into a text field and press a button to confirm\n\n2 - Add the activities statistics, type the statistic name into a text field, select it's type in a dropdown menu, and then press a button to add it\n\n3 - Add any base values for statistics, you select a statistic using a dropdown menu, and then input the basic value into the text field below.\n\nAnd that's all it takes, just do those 3 steps and you'll have an activity!"
            
            // Create a button to go to next page, and one to skip the tutorial
            contentManager.currentOptions = [(-11,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -11:  // Tutorial Text 4 -> Text explaining how to use my app
            contentManager.currentDisplay = "But just having an activity isn't enough, you need to have some players otherwise there's not much point to the application. To make players, you follow another easy 3 step procedure\n\n1 - Add the players name, once again in a text field\n\n2 - Set the players statistics using the same method as setting basic statistics for an activity\n\n3 - Then you can decide if you want the player to be part of a team or group, allowing them to be more easily sorted.\n\nAnd that's all it needs, just 3 easy steps and you can fill up your activity with any player you'd need!"
            
            // Create a button to go to next page, and one to skip the tutorial
            contentManager.currentOptions = [(-10,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -10:  // Tutorial Text 5 -> Text explaining how to use my app
            contentManager.currentDisplay = "And that's all you'll need to use my program! There are some complicated features later on, such as my sorting and searching algorithms, but those will be covered when you get to them. No reason to overcomplicate you experience right now.\n\nGood luck with your storing and managing of activities!"
            
            // Create a button to end the tutorial
            contentManager.currentOptions = [(0,"Begin The Program",1)]
            
            // Some blank cases just incase I ever need to add something to the login phase or the tutorial phase
        case -9: break
        case -8: break
        case -7: break
        case -6: break
        case -5: break
        case -4: break
        case -3: break
            
        case -2:  // Program Intro
            contentManager.currentDisplay = "Good luck with your storing and managing of activities!"
            
            // Create a button for starting the program
            contentManager.currentOptions = [(0,"Begin The Program",1)]
            
        case -1: // Seperated Display (Probs not gonna use, but good to have just in case)
            if contentManager.displaySeperate.count > 1 {
                contentManager.currentDisplay = contentManager.displaySeperate.first!
                contentManager.displaySeperate.removeFirst()
                contentManager.currentOptions = [(-1, "\(contentManager.repeatedString)", 1)]
            } else {
                contentManager.currentOptions = [(contentManager.returnPoint, "\(contentManager.exitString)", 1)]
            }
            
        case 0: // Main Screen
            contentManager.currentDisplay = "Hello \(user.details.username), what do you want to do?"
            
            // Create a button for viewing activities, a button to modify settings, and a button for logging out of the account
            contentManager.currentOptions = [(1,"View Activities",1),(0,"Modify System Settings",1),(0,"Log Out",1)]
            saveGameData()
        case 1: // View Activities
            clearTextFieldData()
            
            // If user has no activities then tell them to make activity
            if user.activities.isEmpty {
                contentManager.currentDisplay = "You currently don't have any activites, to create a new activity press \"Create New Activity\""
                
                // Create a button for creating new activities, and a button to exit to menu
                contentManager.currentOptions = [(2,"Create New Activity",1),(0,"Exit",1)]
                
                // Otherwise display activities and let them select
            } else {
                contentManager.currentDisplay = "Please select the activity that you want to view using the dropdown menu. Or press \"Create New Activity\" to create a new activity."
                
                // Create a tbl-dropdown combo for activities, a button to view activities, a button to create a new activity, and a button to exit the page
                contentManager.currentOptions = [(0,"Activity",7),(7,"View Activity",1),(2,"Create New Activity",1),(0,"Exit",1)]
                
                // Set the table view to show activities and set the dropdown to match the tableview
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for activity in user.activities {
                    contentManager.tableValues.append((activity.name,""))
                    contentManager.storedDropdowns.append(activity.name)
                }
            }
        case 2: // Give Activity Name
            clearTextFieldData()
            contentManager.currentDisplay = "You have decided to create a new activity, what would you like it's name to be?"
            
            // Create a text field for the name, a button to input the name, and a button to exit the page
            contentManager.currentOptions = [(0,"Activity Name", 2),(3,"Create Activity",1), (1,"Exit Menu",1)]
        case 3: // Assign Activity Name --- Add Activity Statistics
            // Check that they did input a name
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give an activity the name of \" \". That would just not work with the rest of my code. Please give it an actual name"
                
                // Create a button to exit the page
                contentManager.currentOptions = [(2,"Exit",1)]
                
                // If they did, ensure that the name isn't already being used
            } else {
                var dupeName: Bool = false
                for activity in user.activities {
                    if activity.name == contentManager.savedTextfieldInformation[0] {
                        dupeName = true
                    }
                }
                
                // If name is already used then have them select a new name
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give an activity a name that's already been used. Please give it a different name"
                    
                    // Create a button to exit the page
                    contentManager.currentOptions = [(2,"Exit",1)]
                    
                    // If the name isn't already used, then let them input the statistics for that activity
                } else {
                    contentManager.currentDisplay = "Please input the statistics that will be used for activity \(contentManager.savedTextfieldInformation[0]).\n\nTo do this, write down the statistic name in the text field, and then exit the text field to add it to the table."
                    
                    // Create a tbl-textField for statistics, a button for inputing the statistics, and a button to exit the menu
                    contentManager.currentOptions = [(0,"Statistic",8),(4,"Finalise Statistics",1),(1,"Exit Menu",1)]
                    
                    // Make the table start out with a placeholder statistic that has no associated value
                    contentManager.tableValues = [("Placeholder","")]
                }
            }
        case 4: // Adding Values
            contentManager.currentDisplay = "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use."
            
            // Create a tbl-dropdown-textField for the statistic, a button to input the statistics, and a button to exit the page
            contentManager.currentOptions = [(0,"Statistic",6), (5,"Finalise Statistics",1), (1,"Exit Menu",1)]
            
            // Set all values to start with 0 as the basic
            for (index,_) in contentManager.tableValues.enumerated() {
                contentManager.tableValues[index].value = "0"
            }
        case 5: // Select Activity Type
            contentManager.currentDisplay = "This activity can be further customised. You have three choices for what type of activity you want it to be:\n\nOption 1 - The activity will have both groups and teams, meaning you can split up players two seperate times, such as age group and then by division.\n\nOption 2 - The activity will have teams, meaning you can split players up based on just one category like division or age group.\n\nOption 3 - The activity won't have groups or teams, instead just stores all the players together.\n\nWhich method would you like to use?\n"
            
            // Create a button for each of the 3 options, and 1 button to exit the page
            contentManager.currentOptions = [(6,"Option 1",1),(6,"Option 2",1),(6,"Option 3",1),(1,"Exit Menu",1)]
        case 6: // Finalise Activity Creation
            
            contentManager.currentDisplay = "Congratulations, you have successfully created the activity \(contentManager.savedTextfieldInformation[0]). This activity has \(contentManager.tableValues.count) statistics being tracked, and uses player storage Option \(sender.titleLabel!.text!.last!)"
            // Create Activity Here
            let newActivity: Activity = Activity(name: contentManager.savedTextfieldInformation[0], storageType: 0, people: [], groups: [], teams: [], combined: StatisticHolder(description: "Overall Statistics", statistics: []), overallStatistics: [])
            
            // Add statistics and values to the activity
            for (title,value) in contentManager.tableValues {
                newActivity.overallStatistics.append(Statistic(name: title, value: (Float(value) ?? 0), rule: []))
            }
            
            // Set the activity type
            // 1 - Type 1 means it stores groups and teams
            // 2 - Type 2 means it stores teams
            // 3 - Type 3 means it stores just a big list of players
            newActivity.storageType = Int(String(sender.titleLabel!.text!.last!))!
            
            // Add the activity and save the program
            user.activities.append(newActivity)
            saveGameData()
            
            contentManager.currentOptions = [(1,"Exit Menu",1)]
        case 7: // View Activity
            // Save data since some later cases send the user back here
            saveGameData()
            
            // Reset the group, team and player values to avoid later issues
            contentManager.selectedValues.group = -1
            contentManager.selectedValues.team = -1
            contentManager.selectedValues.player = -1
            
            // Set the selected activity to whichever value the user selected in the dropdown menu
            if sender.titleLabel!.text == "View Activity" {
                contentManager.selectedValues.activity = contentManager.savedDropdownInformation
            }
            
            // Get the activity as it's own constant for ease of use
            let useActivity: Activity = user.activities[contentManager.selectedValues.activity]
            
            contentManager.currentDisplay = "You are currently viewing \(useActivity.name), an activity that is tracking \(useActivity.overallStatistics.count) statistics for a total of \(useActivity.people.count) people"
            
            
            // Create a button for viewing the activity, and a button for viewing the players in the activity
            contentManager.currentOptions = [(21,"View Activity Details",1), (12,"View All Players",1)]
            
            switch useActivity.storageType {
                // If the activity has groups and teams, make a button for each of those
            case 1: contentManager.currentOptions += [(8,"View Groups",1), (10,"View Teams",1)]
                
                // If the activity just has teams, with no groups, make a button to view the teams
            case 2: contentManager.currentOptions += [(10,"View Teams",1)]
            default: break
            }
            
            // Add a button to exit the page
            contentManager.currentOptions += [(1,"Exit Menu",1)]
            
        case 8: // Select Group
            // Reset the team and player values to avoid later issues
            contentManager.selectedValues.team = -1
            contentManager.selectedValues.player = -1
            
            // Get the activity as it's own constant for ease of use
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // If no groups exist then have the user make a new group
            if activity.groups.isEmpty {
                contentManager.currentDisplay = "You currently don't have any groups, to create a new group press \"Create New Group\""
                
                // Create a button to create a new group, and a button to exit the page
                contentManager.currentOptions = [(37,"Create New Group",1),(7,"Exit",1)]
                
                // Otherwise display groups and let them select
            } else {
                contentManager.currentDisplay = "Please select the group that you want to view using the dropdown menu. Or press \"Create New Group\" to create a new group."
                
                // Create a tbl-dropdown for the groups, a button to view a group, a button to create a group, and a button to exit the page
                contentManager.currentOptions = [(0,"Group",7),(9,"View Group",1),(37,"Create New Group",1),(7,"Exit Menu",1)]
                
                // Set the table view to show groups and set the dropdown to match the tableview
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for group in activity.groups {
                    contentManager.tableValues.append((group.name,""))
                    contentManager.storedDropdowns.append(group.name)
                }
            }
        case 9: // View Group
            // Save data since some later cases send the user back here
            saveGameData()
            
            // Reset the team and player values to avoid later issues
            contentManager.selectedValues.team = -1
            contentManager.selectedValues.player = -1
            
            // Set the selected activity to whichever value the user selected in the dropdown menu
            if sender.titleLabel!.text == "View Group" {
                contentManager.selectedValues.group = contentManager.savedDropdownInformation
            }
            
            // Get the activity as it's own constant for ease of use
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            let group: Group = activity.groups[contentManager.selectedValues.group]
            
            contentManager.currentDisplay = "You are currently viewing \(group.name), a group that has \(group.people.count) people, and \(group.teams.count) teams."
            
            
            // Create a button for viewing the activity, and a button for viewing the players in the activity
            contentManager.currentOptions = [(21,"View Group Details",1), (10,"View Teams",1), (12,"View All Players In Group",1)]
            
            // Add a button to exit the page
            contentManager.currentOptions += [(7,"Exit Menu",1)]
            
        case 10: // Select Team
            
            /*
             Okay so the code below is kinda complex so I'm going to summarise it here and explain why it's complex:
             
             Teams are stored in both the Group and the Activity, so there are teams that are only in an activity, and teams that are in both group and activity
             
             So when displaying teams, we need to check which value is being accessed, aka is the user viewing teams for the whole activity or teams for a specific group.
             
             Basically it checks which one the user is trying to view, and displays those teams
             */
            
            var noTeams: Bool = false
            
            // Declare activity here for ease of use
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Declare the array of teams
            var useTeams: [Team] = []
            
            // If the activity stores groups and teams
            if activity.storageType == 1 {
                
                // And the user is viewing the teams for activity
                if contentManager.selectedValues.group == -1 {
                    
                    // Then use activity teams
                    if activity.teams.isEmpty {
                        noTeams = true
                    } else {
                        useTeams = activity.teams
                    }
                    
                    // Otherwise use group teams
                } else {
                    
                    // Set group here for ease of use
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    if group.teams.isEmpty {
                        noTeams = true
                    } else {
                        useTeams = group.teams
                    }
                }
                // If the activity doesn't have groups, then just check regular activity teams
            } else {
                if activity.teams.isEmpty {
                    noTeams = true
                } else {
                    useTeams = activity.teams
                }
            }
            
            // If no teams exist then have the user make a team
            if noTeams {
                contentManager.currentDisplay = "You currently don't have any teams, to create a new team press \"Create New Team\""
                
                // Create a button to create a new group, and a button to exit the page
                contentManager.currentOptions = [(41,"Create New Team",1),(7,"Exit",1)]
                
                // Otherwise let the user select the team
            } else {
                contentManager.currentDisplay = "Please select the team that you want to view using the dropdown menu. Or press \"Create New Team\" to create a new team."
                
                // Create a tbl-dropdown for the groups, a button to view a group, a button to create a group, and a button to exit the page
                contentManager.currentOptions = [(0,"Team",7),(11,"View Team",1),(41,"Create New Team",1),(7,"Exit Menu",1)]
                
                // Display the players names in the tableValues
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for team in useTeams {
                    contentManager.tableValues.append((team.name,""))
                    contentManager.storedDropdowns.append(team.name)
                }
            }
            
        case 11: // View Team
            // Save data since some later cases send the user back here
            saveGameData()
            
            // Reset the team and player values to avoid later issues
            contentManager.selectedValues.player = -1
            
            // Set the selected activity to whichever value the user selected in the dropdown menu
            if sender.titleLabel!.text == "View Team" {
                contentManager.selectedValues.team = contentManager.savedDropdownInformation
            }
            
            // Get the activity as it's own constant for ease of use
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            var team: Team?
            
            if contentManager.selectedValues.group != -1 {
                let group: Group = activity.groups[contentManager.selectedValues.group]
                team = group.teams[contentManager.selectedValues.team]
            } else {
                team = activity.teams[contentManager.selectedValues.team]
            }
            
            contentManager.currentDisplay = "You are currently viewing \(team!.name), a team that has \(team!.people.count) people."
            
            // Create a button for viewing the activity, and a button for viewing the players in the activity
            contentManager.currentOptions = [(21,"View Team Details",1), (45, "Input Statistics For Team",1), (12,"View Players For Team",1)]
            
            // Add a button to exit the page
            
            if contentManager.selectedValues.group == -1 {
                contentManager.currentOptions += [(7,"Exit Menu",1)]
            } else {
                contentManager.currentOptions += [(9,"Exit Menu",1)]
            }
        case 12: // Viewing Players
            
            // This array is used to store the people that need to be displayed
            var displayPeople: [Person] = []
            
            // Figure out what to do based on what the button the user pressed
            switch sender.titleLabel!.text {
                // If this is to view all players then display all players for the activity
            case "View All Players":
                let activity: Activity = user.activities[contentManager.selectedValues.activity]
                displayPeople = activity.people
                
                // If this is to view players for a group then display players for the selected group
            case "View Players For Group":
                let activity: Activity = user.activities[contentManager.selectedValues.activity]
                let group: Group = activity.groups[contentManager.selectedValues.group]
                displayPeople = group.people
                
                // If this is to view players for a team then display players for the selected team
            case "View Players For Team":
                // If the user is viewing the players for a team that isn't within a group, then get activity-team
                if contentManager.selectedValues.group == -1 {
                    let activity: Activity = user.activities[contentManager.selectedValues.activity]
                    let team: Team = activity.teams[contentManager.selectedValues.team]
                    displayPeople = team.people
                    
                    // Otherwise if the user is viewing the players for a team that is within a group, then get activity-group-team
                } else {
                    let activity: Activity = user.activities[contentManager.selectedValues.activity]
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    let team: Team = group.teams[contentManager.selectedValues.team]
                    displayPeople = team.people
                }
            case "View All Players In Group":
                let activity: Activity = user.activities[contentManager.selectedValues.activity]
                let group: Group = activity.groups[contentManager.selectedValues.group]
                displayPeople = group.people
            default: break
            }
            
            // If no people are in the array then have the user add a new player
            if displayPeople.isEmpty {
                contentManager.currentDisplay = "Currently your selection doesn't have any players, to create a new player, press \"Add New Player\""
                
                // Create a button to create a new player, and a button to exit the page
                contentManager.currentOptions = [(13,"Add New Player",1)]
                
                // Make the exit button go to the right place
                switch sender.titleLabel!.text {
                case "View All Players": contentManager.currentOptions.append((7,"Exit",1))
                case "View All Players In Group", "View Players For Group": contentManager.currentOptions.append((9,"Exit",1))
                case "View Players For Team": contentManager.currentOptions.append((11,"Exit",1))
                default: break
                }
            } else {
                // Otherwise let them select the player they want to view
                contentManager.currentDisplay = "Please select the player that you want to view using the dropdown menu. Or press \"Add New Player\" to input a new player."
                
                // Create a tbl-dropdown for the player, a button for viewing a player, a button to create a new player, and a button to exit the page
                contentManager.currentOptions = [(0,"Player",7), (22,"View Player",1), (13,"Add New Player",1)]
                
                // Make the exit button go to the right page
                switch sender.titleLabel!.text {
                case "View All Players": contentManager.currentOptions.append((7,"Exit",1))
                case "View All Players In Group", "View Players For Group": contentManager.currentOptions.append((9,"Exit",1))
                case "View Players For Team": contentManager.currentOptions.append((11,"Exit",1))
                default: break
                }
                
                // Display the players names in the tableValues
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for player in displayPeople {
                    contentManager.tableValues.append((player.details.name,""))
                    contentManager.storedDropdowns.append(player.details.name)
                }
            }
        case 13: // Create Player -> Assign Name
            contentManager.currentDisplay = "What would you like this player to be named?"
            
            // Create a text field with the name, a button to input the name, and a button to exit the menu
            contentManager.currentOptions = [(0,"Name",2), (14,"Submit Name",1), (7,"Exit Menu",1)]
            
            clearTextFieldData()
        case 14: // Create Player -> Check Name / Add Statistics
            // Check that name isn't blank
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give a player a blank name. That would just not work with the rest of my code. Please give them an actual name"
                
                // Create a button to exit the menu
                contentManager.currentOptions = [(13,"Exit",1)]
            } else {
                // If name isn't blank, then make sure that no other player within the activity has the same name
                var dupeName: Bool = false
                let activity: Activity = user.activities[contentManager.selectedValues.activity]
                for player in activity.people {
                    if player.details.name == contentManager.savedTextfieldInformation[0] {
                        dupeName = true
                    }
                }
                // If they do have the same name then make the user change it
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give a player a name that's already been used. Please give it a different name"
                    
                    // Create a button to exit the menu
                    contentManager.currentOptions = [(13,"Exit",1)]
                } else {
                    // Otherwise, let the user decide whether to input some base statistics or not
                    contentManager.currentDisplay = "Within my application, the players that you create are able to hold statistics from a given period of time, such as from a match or a training or any kind of event\n\nIf you have one singular events data to input, then please press \"Input Statistics\".\n\nHowever, if you either don't have any statistics or have more than one events worth of statistics, please press \"Finalise Player\", and add the statistics in later."
                    
                    // Create a button to input statistics for the player, and a button to input the player
                    contentManager.currentOptions = [(16,"Input Statistics",1), (15,"Finalise Player",1)]
                    contentManager.tableValues = []
                }
            }
            
        case 15: // Input Player
            contentManager.currentDisplay = "If you are 100% certain about inputting this player to your activity, please press \"Input Player\", otherwise please press \"Exit Menu\""
            
            // Create a button to input the player and a button to exit the page
            contentManager.currentOptions = [(17,"Input Player",1), (7,"Exit Menu",1)]
            
        case 16: // Input Player Statistics While Creating
            contentManager.currentDisplay = "Please enter the statistics for player \(contentManager.savedTextfieldInformation[0]) using the text field."
            
            // Create a tbl-dropdown-textField for the statistic, and a button to input the statistics
            contentManager.currentOptions = [(0,"Statistic",6),(17,"Finalise Statistics",1)]
            
            // Have the tableview show all of the players statistics, with their basic values
            contentManager.tableValues = []
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            for statistic in activity.overallStatistics {
                if statistic.rule.isEmpty {
                    contentManager.tableValues.append((title: statistic.name, value: String(statistic.value)))
                }
            }
            
        case 17: // Player Created
            contentManager.currentDisplay = "The new player, \(contentManager.savedTextfieldInformation[0]), has successfully been created!"
            
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Create the player
            let newPlayer: Person = Person(details: PersonDetails(name: contentManager.savedTextfieldInformation[0], uniqueID: user.playerCount, group: FixedStorage(index: -1, name: "", id: -1), team: FixedStorage(index: -1, name: "", id: -1)), currentStatistics: StatisticHolder(description: "Current", statistics: []), pastPeriods: [:])
            user.playerCount += 1
            
            // If the player is being created with stats then do that here
            if !contentManager.tableValues.isEmpty {
                
                // Store the index of auto rules and the index of the table
                var recordedIndex: [Int] = []
                var tableIndex: Int = 0
                
                // Run through the actual statistics
                for (index,statistic) in activity.overallStatistics.enumerated() {
                    
                    // If the statistic isn't an auto calculation then just add it
                    if statistic.rule.isEmpty {
                        var newStatistic: Statistic = statistic
                        
                        // Check if they gave it a value
                        if contentManager.tableValues[tableIndex].value != "" {
                            newStatistic.value = Float(contentManager.tableValues[tableIndex].value)!
                        }
                        
                        // Add the statistic
                        newPlayer.currentStatistics.statistics.append(newStatistic)
                        
                        // One value from the table has been used
                        tableIndex += 1
                        
                        // If the rule is an automatic calcualtion then handle that later
                    } else {
                        recordedIndex.append(index)
                    }
                }
                
                // Handle the automatic calculations
                for index in recordedIndex {
                    // Insert them to the correct point in the array
                    newPlayer.currentStatistics.statistics.insert(activity.overallStatistics[index], at: index)
                    
                    // Get the calculation
                    let rule: Calculation = newPlayer.currentStatistics.statistics[index].rule[0]
                    
                    // Set the value of this statistic to the result of the calculation
                    newPlayer.currentStatistics.statistics[index].value = rule.run(inputPerson: newPlayer.currentStatistics)
                }
                
                // Set the past periods statistics to reflect these initial input statistics
                newPlayer.pastPeriods[0] = newPlayer.currentStatistics
                newPlayer.pastPeriods[0]?.description = "Starting Stats"
            }
            
            // Add them to the activity
            activity.people.append(newPlayer)
            
            // If the player is in a team within a group
            if contentManager.selectedValues.group != -1 && contentManager.selectedValues.team != -1 {
                // Add the player to the group
                let group: Group = activity.groups[contentManager.selectedValues.group]
                group.people.append(newPlayer)
                
                // Add the player to the team
                let team: Team = group.teams[contentManager.selectedValues.team]
                team.people.append(newPlayer)
                
                // Update the players details
                newPlayer.details.getFrom([team,group])
                
                // If the player is just in a group
            } else if contentManager.selectedValues.group != -1 {
                // Add the player to the group
                let group: Group = activity.groups[contentManager.selectedValues.group]
                group.people.append(newPlayer)
                
                // Update the players details
                newPlayer.details.getFrom(group)
                
                // If the player is just in a team
            } else if contentManager.selectedValues.team != -1 {
                // Add the player to the team
                let team: Team = activity.teams[contentManager.selectedValues.team]
                team.people.append(newPlayer)
                
                // Update the players details
                newPlayer.details.getFrom(team)
            }
            
            saveGameData()
            
            // Create a button to exit the page
            contentManager.currentOptions = [(7,"Exit Menu",1)]
            
        case 18: // View Player Statistics Screen
            
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            var player: Person?
            
            // Figure out if player is from all players or just from group or team players
            if contentManager.selectedValues.group == -1 {
                
                // If not in group and not in team then it's just from activity
                if contentManager.selectedValues.team == -1 {
                    player = activity.people[contentManager.selectedValues.player]
                    
                    // If not in group but in team, then it's from activity-team
                } else {
                    let team: Team = activity.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            } else {
                
                // If in group but not in team, then it's from activity-group
                if contentManager.selectedValues.team == -1 {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    player = group.people[contentManager.selectedValues.player]
                    
                    // If in group and in team, then it's from activity-group-team
                } else {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    let team: Team = group.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            }
            
            // Display all of the players past values
            contentManager.tableValues = [("Current Values","")]
            for (_,pastPeriod) in player!.pastPeriods {
                contentManager.tableValues.append((title: pastPeriod.description, value: ""))
            }
            
            contentManager.currentDisplay = "What set of statistic values do you want to view"
            contentManager.currentOptions = [(0,"Period",7),(19,"View Statistics",1), (22, "Exit Menu",1)]
            
        case 19: // View Player Statistics Screen
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            var player: Person?
            
            // Figure out if player is from all players or just from group or team players
            if contentManager.selectedValues.group == -1 {
                
                // If not in group and not in team then it's just from activity
                if contentManager.selectedValues.team == -1 {
                    player = activity.people[contentManager.selectedValues.player]
                    
                    // If not in group but in team, then it's from activity-team
                } else {
                    let team: Team = activity.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            } else {
                
                // If in group but not in team, then it's from activity-group
                if contentManager.selectedValues.team == -1 {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    player = group.people[contentManager.selectedValues.player]
                    
                    // If in group and in team, then it's from activity-group-team
                } else {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    let team: Team = group.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            }
            
            
            // TODO: ADD FUNCTIONALITY HERE TO ACTUALLY DISPLAY THE STATISTICS
            
            // If they selected the first value then they want to view current overall
            if contentManager.selectedDropdownIndex == 0 {
                player!.currentStatistics
            
            // If they selected any other value then they're viewing past statistics
            } else {
                player!.pastPeriods[contentManager.selectedDropdownIndex - 1]
            }
            
            
            
            
        case 20: break
        case 21: // View Activity Details
            saveGameData()
            // Get the activity
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Display the name
            contentManager.currentDisplay = "Activity: \(activity.name)"
            
            //MARK: Maybe put some more activity details here
            
            // Create a table that shows the statistics, a button to edit the statistics, and a button to exit the page
            contentManager.currentOptions = [(0,"Statistics",9), (23,"Edit Statistics",1), (7,"Exit Menu",1)]
            
            // Showcase the statistics for the activity
            contentManager.tableValues = []
            for statistic in activity.overallStatistics {
                if statistic.rule.isEmpty {
                    contentManager.tableValues.append((title: statistic.name,value: "Base Value: " + String(statistic.value)))
                } else {
                    contentManager.tableValues.append((title: statistic.name, value: "Rule: " + statistic.rule[0].toString()))
                }
            }
            
        case 22: // View Player
            // Get activity and player
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            var player: Person?
            
            // Set the value of the selected player
            if sender.titleLabel!.text == "View Player" {
                contentManager.selectedValues.player = contentManager.savedDropdownInformation
            }
            
            // Figure out if player is from all players or just from group or team players
            if contentManager.selectedValues.group == -1 {
                
                // If not in group and not in team then it's just from activity
                if contentManager.selectedValues.team == -1 {
                    print(activity.people)
                    print(contentManager.selectedValues.player)
                    player = activity.people[contentManager.selectedValues.player]
                    
                    // If not in group but in team, then it's from activity-team
                } else {
                    let team: Team = activity.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            } else {
                
                // If in group but not in team, then it's from activity-group
                if contentManager.selectedValues.team == -1 {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    player = group.people[contentManager.selectedValues.player]
                    
                    // If in group and in team, then it's from activity-group-team
                } else {
                    let group: Group = activity.groups[contentManager.selectedValues.group]
                    let team: Team = group.teams[contentManager.selectedValues.team]
                    player = team.people[contentManager.selectedValues.player]
                }
            }
            
            // Unsure exactly what to display here for now, so it called on the display function
            contentManager.currentDisplay = player!.display()
            
            // Create a button to exit the menu
            contentManager.currentOptions = [(18, "View Player Statistics", 1), (45, "Input Statistics For Player",1), (7,"Exit Menu",1)]
            
            
        case 23: // Edit Activity Statistics
            contentManager.currentDisplay = "What do you want to edit?"
            contentManager.currentOptions = [(24,"Change Base Values",1), (26,"Add New Statistic",1), (30,"Add Calculation",1), (21,"Exit Menu",1)]
        case 24: // Change Base Values
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            contentManager.currentDisplay = "Edit the base values using the below text field"
            
            // Create a tbl-dropdown-textField for the statistic, a button to input the statistics, and a button to exit the page
            contentManager.currentOptions = [(0,"Statistic",6), (25,"Finalise Statistics",1), (21,"Exit Menu",1)]
            
            // Display the statistic values
            contentManager.tableValues = []
            for statistic in activity.overallStatistics {
                if statistic.rule.isEmpty {
                    contentManager.tableValues.append((title: statistic.name, value: String(statistic.value)))
                }
            }
        case 25: // Base Values Finalised
            var changeNumber: Int = 0
            var changeList: [String] = []
            
            // Get activity
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Run through the statistics
            var tableIndex: Int = 0
            for (index,statistic) in activity.overallStatistics.enumerated() {
                if statistic.rule.isEmpty {
                    // Change the values to match the table values
                    if activity.overallStatistics[index].value != Float(contentManager.tableValues[tableIndex].value)! {
                        
                        // Record that the change occured
                        changeList.append("\(statistic.name): \(activity.overallStatistics[index].value) -> \(Float(contentManager.tableValues[tableIndex].value)!)")
                        changeNumber += 1
                        
                        // Perform the change
                        activity.overallStatistics[index].value = Float(contentManager.tableValues[tableIndex].value)!
                        
                    }
                    
                    // Move to the next spot in the table
                    tableIndex += 1
                }
            }
            
            // If it's not one value, then add an s to value to make it values
            var plural: String = ""
            if changeNumber != 1 {
                plural = "s"
            }
            
            // Display the changes to the user in a table view
            contentManager.currentDisplay = "You have changed \(changeNumber) base value\(plural)."
            if changeNumber != 0 {
                contentManager.currentOptions = [(0,"Statistics",9), (21,"Exit Menu",1)]
                contentManager.tableValues = []
                for text in changeList {
                    contentManager.tableValues.append((text,""))
                }
            } else {
                contentManager.currentOptions = [(21,"Exit Menu",1)]
            }
        case 26: // Add New Statistic
            contentManager.currentDisplay = "Please input any new statistics to this activity using the text field"
            
            // Create a tbl-textField for statistics, a button for inputing the statistics, and a button to exit the menu
            contentManager.currentOptions = [(0,"Statistic",8),(27,"Finalise Statistics",1),(21,"Exit Menu",1)]
            
            // Make the table start out with a placeholder statistic that has no associated value
            contentManager.tableValues = [("Placeholder","")]
        case 27: // Add Base Values
            contentManager.currentDisplay = "Please add any basic statistic values to the new statistics."
            
            // Create a tbl-dropdown-textField for the statistic, a button to input the statistics, and a button to exit the page
            contentManager.currentOptions = [(0,"Statistic",6), (28,"Finalise Statistics",1), (21,"Exit Menu",1)]
            
            // Set all values to start with 0 as the basic
            for (index,_) in contentManager.tableValues.enumerated() {
                contentManager.tableValues[index].value = "0"
            }
        case 28: // Confirm Input Statistics
            contentManager.currentDisplay = "Are you certain that you would like to add these new statistics to your activity?"
            contentManager.currentOptions = [(29,"Yes",1), (21,"No",1)]
        case 29: // Input Statistics
            // Get the activity
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Run through each activity
            for (title,value) in contentManager.tableValues {
                
                // Make sure there's no duplicate statistics
                if activity.overallStatistics.searchNamesFor(input: title) == -1 {
                    
                    let newStatistic: Statistic = Statistic(name: title, value: Float(value)!, rule: [])
                    // Add the statistic
                    activity.addStatistic(newStatistic)
                }
            }
            contentManager.currentDisplay = "The new statistics have been added to your activity."
            contentManager.currentOptions = [(21,"Exit Menu",1)]
            
        case 30: // Confirm Automatic Calculation
            contentManager.currentDisplay = "Are you sure you wish to create an automatic calculation?"
            contentManager.currentOptions = [(31,"Yes",1),(21,"No",1)]
        case 31: // Check Automatic Calculation
            clearTextFieldData()
            contentManager.currentDisplay = "To create an automatic calculation you will need 3 inputs:\n\n1- The first value, this can be either a statistic from the activity, or a number\n\n2- The operator, being either a +, -, * or / \n\n3- The second value, this can be either a statistic from the activity or a number\n\nYour input should follow the format \"Value1 Operator Value2\". Once you're certain you know how to make this automatic calculation, please press \"Continue\""
            contentManager.currentOptions = [(32,"Continue",1),(21,"Exit",1)]
        case 32: // Create Automatic Calculation
            
            contentManager.currentOptions = [(0,"Statistics",9), (0,"Calculation",2), (33,"Input Automatic Calculation",1)]
            
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Display all of the statistics to help the player make their rule
            contentManager.tableValues = []
            for statistic in activity.overallStatistics {
                
                // Note that this one doesn't use "if rule.isEmpty()
                // This is so you can use more complex rules such as calculating kills + assists as one calculation and then making another rule that does (kills+assists) / deaths for the proper kda
                
                contentManager.tableValues.append((statistic.name,""))
            }
        case 33: // Check Automatic Calculation
            let ruleWords: [String] = contentManager.savedTextfieldInformation[0].components(separatedBy: " ")
            
            // Perform checks on the players input
            let lengthCheck: Bool = (ruleWords.count == 3)
            let primaryCheck: Bool = ruleWords[0].isValidComponent()
            let operatorCheck: Bool = ruleWords[1].isValidOperator()
            let secondaryCheck: Bool = ruleWords[2].isValidComponent()
            let crashCheck: Bool = (ruleWords[1] == "/" && ruleWords[2] == "0")
            
            // If it failed any of the checks then tell them what they did wrong
            if !lengthCheck || !primaryCheck || !operatorCheck || !secondaryCheck || !crashCheck {
                contentManager.currentDisplay = "Oh dear, there seem to be some errors in your code:\n\n"
                
                if !lengthCheck {
                    contentManager.currentDisplay += "Your calculation contains more than 3 words\n\n"
                }
                if !primaryCheck {
                    contentManager.currentDisplay += "Your first value is not a number or a statistic\n\n"
                }
                if !operatorCheck {
                    contentManager.currentDisplay += "Your operator is not one of the permissable operators\n\n"
                }
                if !secondaryCheck {
                    contentManager.currentDisplay += "Your second value is not a number or a statistic\n\n"
                }
                if !crashCheck {
                    contentManager.currentDisplay += "You are dividing a value by 0... Are you seriously trying to break my code with a divide by 0? That's an insanely lame thing to do...\n\n"
                }
                
                contentManager.currentDisplay += "Please fix these problems if you wish to create the calculation."
                
                // Let them either give up or try again
                contentManager.currentOptions = [(33,"Try Again",1), (21,"Give Up",1)]
            } else {
                contentManager.currentDisplay = "Let's confirm that your rule is correct:\n\n"
                
                // Display the first value
                contentManager.currentDisplay += "First Value: \(ruleWords[0])"
                if ruleWords[0].isFloat() {
                    contentManager.currentDisplay += " (Number)\n"
                } else {
                    contentManager.currentDisplay += " (Statistic)\n"
                }
                
                // Display the operator
                contentManager.currentDisplay += "Operator: \(ruleWords[1]) (\(ruleWords[1].described()))\n"
                
                // Display the second value
                contentManager.currentDisplay += "Second Value: \(ruleWords[2])"
                if ruleWords[2].isFloat() {
                    contentManager.currentDisplay += " (Number)\n\n"
                } else {
                    contentManager.currentDisplay += " (Statistic)\n\n"
                }
                
                // Confirm that they have their rule correct
                contentManager.currentDisplay += "Does this look correct to you?"
                contentManager.currentOptions = [(34,"Yes",1), (32,"No",1)]
            }
        case 34: // Get Automatic Calculation Name
            if contentManager.savedTextfieldInformation.count == 2 {
                contentManager.savedTextfieldInformation.removeLast()
            }
            contentManager.currentDisplay = "What do you want to name the statistic that will get it's value from this automatic calculation?"
            
            // Create a text field for the name, a button to input the name, and a button to exit the page
            contentManager.currentOptions = [(0,"Statistic Name", 2),(35,"Create Calculation",1)]
            
        case 35: // Confirm Automatic Calculation Name -> Confirm Creation
            
            // Check that it's name isn't blank
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give it the name of \" \". That would just not work with the rest of my code. Please give it an actual name"
                
                // Create a button to exit the page
                contentManager.currentOptions = [(34,"Exit",1)]
                
                // If the name isn't blank, ensure that the name isn't already being used
            } else {
                var dupeName: Bool = false
                for statistic in user.activities[contentManager.selectedValues.activity].overallStatistics {
                    if statistic.name == contentManager.savedTextfieldInformation[1] {
                        dupeName = true
                    }
                }
                
                // If name is already used then have them select a new name
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give a statistic a name that's already been used. Please give it a different name"
                    
                    // Create a button to exit the page
                    contentManager.currentOptions = [(34,"Exit",1)]
                    
                    // If the name isn't already used, then double check that they want to create it
                } else {
                    contentManager.currentDisplay = "Are you absolutely sure that you want to create the automatic calculation with rule \"\(contentManager.savedTextfieldInformation[0])\" and the name \"\(contentManager.savedTextfieldInformation[1])\"?"
                    
                    // Create buttons to finalise the calculation or to stop making the calculation
                    contentManager.currentOptions = [(36,"Yes",1), (34,"Change Name",1), (21,"Exit Menu",1)]
                }
            }
        case 36: // Perform Creation
            // Get the users code
            let wordSplit: [String] = contentManager.savedTextfieldInformation[0].components(separatedBy: " ")
            
            // Make the calculation from the code
            let newCalculation: Calculation = Calculation(primaryTerm: wordSplit[0], operation: wordSplit[1].toOperator(), secondaryTerm: wordSplit[2])
            
            // Make the statistic using the calculation and name
            let newStatistic: Statistic = Statistic(name: contentManager.savedTextfieldInformation[1], value: 0, rule: [newCalculation])
            
            // Add the statistic to the activity
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            activity.addStatistic(newStatistic)
            
            contentManager.currentDisplay = "Your automatic calculation has been successfully added to your activity."
            contentManager.currentOptions = [(21,"Exit Menu",1)]
            
        case 37:
            clearTextFieldData()
            contentManager.currentDisplay = "You have decided to create a new group, what would you like it's name to be?"
            
            // Create a text field for the name, a button to input the name, and a button to exit the page
            contentManager.currentOptions = [(0,"Group Name", 2),(38,"Create Group",1), (7,"Exit Menu",1)]
        case 38: // Assign Group Name --- Add Group Players
            // Check that they did input a name
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give a group the name of \" \". That would just not work with the rest of my code. Please give it an actual name"
                
                // Create a button to exit the page
                contentManager.currentOptions = [(37,"Exit",1)]
                
                // If they did, ensure that the name isn't already being used
            } else {
                var dupeName: Bool = false
                for group in user.activities[contentManager.selectedValues.activity].groups {
                    if group.name == contentManager.savedTextfieldInformation[0] {
                        dupeName = true
                    }
                }
                
                // If name is already used then have them select a new name
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give a group a name that's already been used. Please give it a different name"
                    
                    // Create a button to exit the page
                    contentManager.currentOptions = [(37,"Exit",1)]
                    
                    // If the name isn't already used, then let them input the statistics for that activity
                } else {
                    if user.activities[contentManager.selectedValues.activity].people.isEmpty {
                        contentManager.currentDisplay = "Since you have no players for this activity, you can immediately finalise group creation. Are you certain you would like to create this group?"
                        contentManager.currentOptions = [(39,"Create Group",1), (7,"Exit Menu",1)]
                    } else {
                        contentManager.currentDisplay = "Your group has been accepted\n\nIf you would like to add players to this group immediately then please press \"Add Players\", but otherwise please press \"Exit Menu\" to exit."
                        contentManager.currentOptions = [(39,"Add Players",1), (7,"Exit Menu",1)]
                    }
                }
            }
        case 39: // Input Players
            if sender.titleLabel!.text == "Create Group" || sender.titleLabel!.text == "Add Players" {
                contentManager.currentDisplay = "Your group has successfully been created."
                
                // Create a button fo rexiting the menu
                contentManager.currentOptions = [(7,"Exit Menu",1)]
                
                // Create the group
                
                let newGroup: Group = Group(name: contentManager.savedTextfieldInformation[0], people: [], teams: [], uniqueID: user.groupCount)
                user.groupCount += 1
                
                user.activities[contentManager.selectedValues.activity].groups.append(newGroup)
                saveGameData()
            } else {
                
                var indexCount: Int = 0
                // Run through the players in the activity
                for player in user.activities[contentManager.selectedValues.activity].people {
                    
                    // Find the ones not in a group
                    if player.details.group.id == -1 && player.details.group.name == "" && player.details.group.index == -1 {
                        
                        // If they match the selected dropdown segment then they're the one that got selected
                        if indexCount == contentManager.selectedDropdownIndex {
                            user.activities[contentManager.selectedValues.activity].groups.last?.people.append(player)
                        // Otherwise we must try again and see if the next one matches
                        } else {
                            indexCount += 1
                        }
                    }
                }
            }
            if sender.titleLabel!.text != "Create Group" {
                contentManager.currentDisplay = "Please select the players that you wish to be in this group through the dropdown menu or tableview, and input them to the activity using the \"Input Player\" button.\n\nWhen you are finished with this step, please press \"Finalise Group\""
                
                // Create a tbl-dropdown for group players, a button for creating the group, and a button to exit the menu
                contentManager.currentOptions = [(0,"Player",7), (39,"Input Player",1), (40,"Finalise Group",1), (7,"Exit Menu",1)]
                
                // Make the table start out with the players that aren't in groups already
                contentManager.tableValues = []
                for player in user.activities[contentManager.selectedValues.activity].people {
                    if player.details.group.id == -1 && player.details.group.name == "" && player.details.group.index == -1 {
                        contentManager.tableValues.append((title: player.details.name, value: ""))
                    }
                }
            }
        case 40: // Finalise Group 100%
            contentManager.currentDisplay = "Your group has successfully been created."
            saveGameData()
            // Create a button fo rexiting the menu
            contentManager.currentOptions = [(1,"Exit Menu",7)]
        case 41: // Create Team
            clearTextFieldData()
            contentManager.currentDisplay = "You have decided to create a new team, what would you like it's name to be?"
            
            // Create a text field for the name, a button to input the name, and a button to exit the page
            contentManager.currentOptions = [(0,"Team Name", 2),(42,"Create Team",1),(7,"Exit Menu",1)]
            
            // If the player is doing this for a group then make the exit button to to the group page
            if contentManager.selectedValues.group != -1 {
                contentManager.currentOptions[2].identifier = 9
            }
            
        case 42: // Assign Team Name --- Add Team Players
            // Check that they did input a name
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give a team the name of \" \". That would just not work with the rest of my code. Please give it an actual name"
                
                // Create a button to exit the page
                contentManager.currentOptions = [(37,"Exit",1)]
                
                // If they did, ensure that the name isn't already being used
            } else {
                var dupeName: Bool = false
                
                // Handle which set of teams to look at
                var useTeams: [Team] = []
                if contentManager.selectedValues.group == -1 {
                    useTeams = user.activities[contentManager.selectedValues.activity].teams
                } else {
                    useTeams = user.activities[contentManager.selectedValues.activity].groups[contentManager.selectedValues.group].teams
                }
                
                // Find if the name is a duplicate
                for team in useTeams {
                    if team.name == contentManager.savedTextfieldInformation[0] {
                        dupeName = true
                    }
                }
                
                // If name is already used then have them select a new name
                if dupeName {
                    contentManager.currentDisplay = "Unfortunately, you cannot give a team a name that's already been used. Please give it a different name"
                    
                    // Create a button to exit the page
                    contentManager.currentOptions = [(41,"Exit",1)]
                    
                    // If the name isn't already used, then let them input the statistics for that activity
                } else {
                    if contentManager.selectedValues.group == -1 {
                        if user.activities[contentManager.selectedValues.activity].people.isEmpty {
                            contentManager.currentDisplay = "Since you have no players for this activity, you can immediately finalise team creation. Are you certain you would like to create this team?"
                            contentManager.currentOptions = [(43,"Create Team",1), (7,"Exit Menu",1)]
                        } else {
                            contentManager.currentDisplay = "Your group has been accepted\n\nIf you would like to add players to this group immediately then please press \"Add Players\", but otherwise please press \"Exit Menu\" to exit."
                            contentManager.currentOptions = [(43,"Add Players",1), (7,"Exit Menu",1)]
                        }
                    } else {
                        if user.activities[contentManager.selectedValues.activity].groups[contentManager.selectedValues.group].people.isEmpty {
                            contentManager.currentDisplay = "Since you have no players for this group, you can immediately finalise team creation. Are you certain you would like to create this team?"
                            contentManager.currentOptions = [(43,"Create Team",1), (9,"Exit Menu",1)]
                        } else {
                            contentManager.currentDisplay = "Your team has been accepted\n\nIf you would like to add players to this team immediately then please press \"Add Players\", but otherwise please press \"Exit Menu\" to exit."
                            contentManager.currentOptions = [(43,"Add Players",1), (9,"Exit Menu",1)]
                        }
                    }
                }
            }
        case 43: // Input Players
            if sender.titleLabel!.text == "Create Team" || sender.titleLabel!.text == "Add Players" {
                contentManager.currentDisplay = "Your team has successfully been created."
                
                // Create a button fo rexiting the menu
                if contentManager.selectedValues.group == -1 {
                    contentManager.currentOptions = [(7,"Exit Menu",1)]
                } else {
                    contentManager.currentOptions = [(9,"Exit Menu",1)]
                }
                
                // Create the team
                
                let newTeam: Team = Team(name: contentManager.savedTextfieldInformation[0], people: [], uniqueID: user.teamCount)
                user.teamCount += 1
                
                user.activities[contentManager.selectedValues.activity].teams.append(newTeam)
                if contentManager.selectedValues.group != -1 {
                    user.activities[contentManager.selectedValues.activity].groups[contentManager.selectedValues.group].teams.append(newTeam)
                }
                
                saveGameData()
            } else {
                var usePlayers: [Person] = []
                
                if contentManager.selectedValues.group == -1 {
                    usePlayers = user.activities[contentManager.selectedValues.activity].people
                } else {
                    usePlayers = user.activities[contentManager.selectedValues.activity].groups[contentManager.selectedValues.group].people
                }
                
                var indexCount: Int = 0
                // Run through the players in the activity
                for player in usePlayers{
                    
                    // Find the ones not in a group
                    if player.details.group.id == -1 && player.details.group.name == "" && player.details.group.index == -1 {
                        
                        // If they match the selected dropdown segment then they're the one that got selected
                        if indexCount == contentManager.selectedDropdownIndex {
                            
                            if contentManager.selectedValues.group == -1 {
                                user.activities[contentManager.selectedValues.activity].teams.last?.people.append(player)
                            } else {
                                user.activities[contentManager.selectedValues.activity].groups[contentManager.selectedValues.group].teams.last?.people.append(player)
                            }
                        // Otherwise we must try again and see if the next one matches
                        } else {
                            indexCount += 1
                        }
                    }
                }
            }
            if sender.titleLabel!.text != "Create Team" {
                contentManager.currentDisplay = "Please select the players that you wish to be in this team through the dropdown menu or tableview, and input them to the activity using the \"Input Player\" button.\n\nWhen you are finished with this step, please press \"Finalise Group\""
                
                // Create a tbl-dropdown for group players, a button for creating the group, and a button to exit the menu
                contentManager.currentOptions = [(0,"Player",7), (43,"Input Player",1), (44,"Finalise Group",1), (7,"Exit Menu",1)]
                if contentManager.selectedValues.group != -1 {
                    contentManager.currentOptions[3].identifier = 9
                }
                
                // Make the table start out with the players that aren't in groups already
                contentManager.tableValues = []
                for player in user.activities[contentManager.selectedValues.activity].people {
                    if player.details.group.id == -1 && player.details.group.name == "" && player.details.group.index == -1 {
                        contentManager.tableValues.append((title: player.details.name, value: ""))
                    }
                }
            }
        case 44: // Finalise Group 100%
            contentManager.currentDisplay = "Your group has successfully been created."
            saveGameData()
            // Create a button fo rexiting the menu
            contentManager.currentOptions = [(7,"Exit Menu",1)]
            
            // If it was sent here from a group then send them back to the group
            if contentManager.selectedValues.group != -1 {
                contentManager.currentOptions[0].identifier = 9
            }
        case 45: // Input Statistics
            contentManager.savedIntegers = []
            contentManager.currentOptions = [(46,"Yes",1), (22,"No",1)]
            
            // Declare some variables
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            var group: Group?
            var team: Team?
            var player: Person?
            
            // Set up the relevant variables
            if contentManager.selectedValues.group != -1 {
                group = activity.groups[contentManager.selectedValues.group]
                team = group!.teams[contentManager.selectedValues.team]
            } else {
                team = activity.teams[contentManager.selectedValues.team]
            }
            
            // Figure out whether it's team statistics or player statistics
            switch sender.titleLabel?.text {
            case "Input Statistics For Team":
                contentManager.savedIntegers = [0]
                contentManager.currentOptions[1].identifier = 11
                
                // Add each of the players to the array of people to look at
                for player in team!.people {
                    contentManager.savedIntegers.append(player.details.uniqueID)
                }
                
                contentManager.currentDisplay = "Are you certain you'd like to input new statistic values for this team?"
            case "Input Statistics For Player":
                
                // Figure out which player is being looked at
                if team == nil {
                    if group == nil {
                        player = activity.people[contentManager.selectedValues.player]
                    } else {
                        player = group!.people[contentManager.selectedValues.player]
                    }
                } else {
                    player = team!.people[contentManager.selectedValues.player]
                }
                
                // Add them to the array of people being looked at
                contentManager.savedIntegers = [0, player!.details.uniqueID]
                
                contentManager.currentDisplay = "Are you certain you'd like to input new statistic values for this player?"
                
            default: break
            }
        case 46: // Add Name
            contentManager.currentDisplay = "Please input the name that you will be giving to this set of statistics.\n\nHere are some examples: \n28/7/25 - Training\nMatch - 28/7"
            contentManager.currentOptions = [(0,"Event Name",2),(47,"Input Name",1)]
            
        case 47: // Check If Adding Statistics -> 47 / 48
            
            // Add 1 to the index that we are checking in the array
            contentManager.savedIntegers[0] += 1
            
            // Get the player that you're meant to be modifying now
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            let playerID: Int = contentManager.savedIntegers[contentManager.savedIntegers[0]]
            let playerIndex: Int = activity.searchPlayersFor(ID: playerID)
            let player: Person = activity.people[playerIndex]
            
            // Check if all the values have been viewed yet
            if contentManager.savedIntegers[0] == contentManager.savedIntegers.count {
                contentManager.currentDisplay = "You are now adding statistics for player \(contentManager.savedIntegers[0]), \(player.details.name). If they were absent from this event then please press \"No Statistics Available\""
                contentManager.currentOptions = [(47,"Add Statistics",1), (50,"No Statistics Available",1)]
            } else {
                contentManager.currentDisplay = "You have successfully added a new set of statistics to your players. Please press the \"Finalise Statistics\" button to allow any calculations to be performed."
                contentManager.currentOptions = [(51,"Finalise Statistics",1),]
            }
        case 48: // Add Statistics Screen
            // Get the player that you're meant to be modifying now
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            let playerID: Int = contentManager.savedIntegers[contentManager.savedIntegers[0]]
            let playerIndex: Int = activity.searchPlayersFor(ID: playerID)
            let player: Person = activity.people[playerIndex]
            
            // Display what the player should input
            contentManager.currentDisplay = "Please input the statistic values for player \(player.details.name) during event \(contentManager.savedTextfieldInformation[0])"
            
            // Create a table-dropdown-text field and a button to finalise
            contentManager.currentOptions = [(0,"Statistic",6), (49,"Finalise Statistics",1)]
            
            // Display the statistics that they need to input
            contentManager.tableValues = []
            for statistic in activity.overallStatistics {
                if statistic.rule.isEmpty {
                    contentManager.tableValues.append((title: statistic.name, value: String(statistic.value)))
                }
            }
        case 49: // Run Added Statistics (Add the statistics to the player), display completion message
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            let playerID: Int = contentManager.savedIntegers[contentManager.savedIntegers[0]]
            let playerIndex: Int = activity.searchPlayersFor(ID: playerID)
            let player: Person = activity.people[playerIndex]
            
            // Create the statistics that are being added
            var newStatistics: StatisticHolder = StatisticHolder(description: contentManager.savedTextfieldInformation[0], statistics: activity.overallStatistics)
            
            // Run through the statistics
            var tableIndex: Int = 0
            for (index,statistic) in newStatistics.statistics.enumerated() {
                
                // If this is a statistic they'd input a value for
                if statistic.rule.isEmpty {
                    
                    // Then set the value and move 1 spot forward in the table
                    newStatistics.statistics[index].value = Float(contentManager.tableValues[tableIndex].value)!
                    tableIndex += 1
                } else {
                    // But if it's an automatic calculation, run the calculation
                    newStatistics.statistics[index].value = statistic.rule[0].run(inputPerson: newStatistics)
                }
            }
            
            player.pastPeriods[player.pastPeriods.count] = newStatistics
            
            // Give player confirmation
            contentManager.currentDisplay = "You have successfully input the values for \(player.details.name) during event \(contentManager.savedTextfieldInformation[0]). "
            
            // Let the player move onto the next person
            contentManager.currentOptions = [(47,"Continue",1)]
        case 50: // No Statistics For This Period
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            let playerID: Int = contentManager.savedIntegers[contentManager.savedIntegers[0]]
            let playerIndex: Int = activity.searchPlayersFor(ID: playerID)
            let player: Person = activity.people[playerIndex]
            
            // Make the statistic input blank
            let newStatistics: StatisticHolder = StatisticHolder(description: contentManager.savedTextfieldInformation[0], statistics: [])
            
            // Input them
            player.pastPeriods[player.pastPeriods.count] = newStatistics
            
            // Give player confirmation
            contentManager.currentDisplay = "You have successfully input the values for \(player.details.name) during event \(contentManager.savedTextfieldInformation[0]). "
            
            // Let the player move onto the next person
            contentManager.currentOptions = [(47,"Continue",1)]
        case 51: // Finished Statistic Input
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            contentManager.savedIntegers.removeFirst()
            
            // Run through each of the people
            for playerIndex in contentManager.savedIntegers {
                activity.people[playerIndex].currentStatistics.statistics = activity.overallStatistics
            }
            
            // Reinitialise the statistics for the activity
            activity.combined.statistics = activity.overallStatistics
            
            // Calculate the total statistics
            activity.calculateCurrentStatistics()
            
            contentManager.currentDisplay = "All calculations have been performed!"
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
            // contentManager.currentDisplay = "Select New List -> Use savedTextField stuff"
            // contentManager.currentDisplay = "Handle Change Group -> Display Success Or Failure Messages -> Apply New Stats"
            // contentManager.currentDisplay = "Viewing Player"
            // contentManager.currentDisplay = "Select New Group / Team -> Send from viewing player"
            // contentManager.currentDisplay = "Handle Change Group -> Display Success Or Failure Messages -> Apply New Stats"
            // contentManager.currentDisplay = "Create New Automatic Statistic Name"
            // contentManager.currentDisplay = "Declare Values and Operations Bit By Bit"
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
    
    // Simulates pressing the up arrow
    @objc func upArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "↑", contentManager.currentOptions[value].type))
        }
    }
    
    // Simulates pressing the down arrow
    @objc func downArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "↓", contentManager.currentOptions[value].type))
        }
    }
    
    // Simulates pressing the left arrow
    @objc func leftArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "←", contentManager.currentOptions[value].type))
        }
    }
    
    // Simulates pressing the right arrow
    @objc func rightArrowPressed(_ sender: UIKeyCommand) {
        let value: Int = checkArrows()
        if value != -1 {
            runFakeButton((contentManager.currentOptions[value].identifier, "→", contentManager.currentOptions[value].type))
        }
    }
    
    // Simulates pressing a button with any given values
    func runFakeButton(_ input: (Int,String,Int)) {
        let buttonInput: UIButton = UIButton()
        buttonInput.tag = input.0
        buttonInput.setTitle(input.1, for: .normal)
        buttonPressed(buttonInput)
    }
    
    // Checks if buttons exist that arrows can be used for
    func checkArrows() -> Int {
        for (index,(_,_,value)) in contentManager.currentOptions.enumerated() {
            if value == 4 {
                return index
            }
        }
        return -1
    }
    
    // Clears any saved text field information
    func clearTextFieldData() {
        contentManager.savedTextfieldInformation = []
    }
    
    // Saves all data from text fields to an array
    func saveTextFieldData() {
        for textField in textFields {
            contentManager.savedTextfieldInformation.append(textField.text ?? "")
        }
        textFields.removeAll()
    }
    
    // Saves the dropdown information from all dropdown menus on the screen
    func saveDropdownData() {
        // Get the dropdowns
        for dropdown in dropdowns {
            let selectedIndex = dropdown.selectedRow(inComponent: 0)
            if selectedIndex >= 0 && selectedIndex < contentManager.storedDropdowns.count {
                // Save the data
                contentManager.savedDropdownInformation = selectedIndex
            } else {
                contentManager.savedDropdownInformation = 0 // Handle invalid selection
            }
        }
        
        // Clear displayed dropdowns
        contentManager.storedDropdowns = []
        dropdowns.removeAll()
    }
    
    // Code that creates visual elements to be displayed on the screen
    func runUpdates(_ sender: UIButton) {
        
        // yOffset is the distance from the top of the screen that UI Elements are given
        var yOffset: CGFloat = 60
        
        // Sets the displayed text at the top of the page as a UILabel
        let displayLabel = UILabel()
        
        // Use the currentDisplay to set the text
        displayLabel.text = contentManager.currentDisplay
        contentManager.currentDisplay = ""
        
        // Make the label wrap and take up as much space as it needs
        displayLabel.numberOfLines = 0
        displayLabel.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 20, height: 0)
        displayLabel.sizeToFit()
        
        // Add the label to the screen
        view.addSubview(displayLabel)
        
        // Make sure we adjust the positions of any other elements based on the text size
        if displayLabel.text != "" {
            yOffset += displayLabel.frame.height + 10
        }
        
        // Used for testing to allow the use of keyboard control to simulate button presses
        // No reason to remove it since this app could still be used on a macbook or other keyboard device
        var index: Int = 0
        
        // Then uses each stored option in contentManager.currentOptions to create elements
        for (identifier, title, type) in contentManager.currentOptions {
            switch type {
            case 1:
                // Creates button
                let button = createButton(with: title, action: #selector(buttonPressed(_:)), color: .systemBlue)
                button.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                
                // Make the button (when pressed) run the specific code in the big switch case
                button.tag = identifier
                
                // Add button to screen
                view.addSubview(button)
                
                // Handling for keyboard controls
                if index < 9 && title != "" {
                    let label = UILabel()
                    label.textColor = .systemBlue
                    label.layer.position.x = 370
                    label.layer.position.y = yOffset + 10
                    label.font = UIFont.systemFont(ofSize: 15)
                    label.text = "[\(index + 1)]"
                    index += 1
                    label.sizeToFit() // Resize label based on content
                    
                    view.addSubview(label)
                }
                
                yOffset += 50
            case 2:
                // Creates a label for the text field
                let label = UILabel()
                label.text = "Enter \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                
                // Add it to the screen
                view.addSubview(label)
                
                yOffset += 30
                
                // Creates a text field
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 40)
                
                // Add it to the screen
                view.addSubview(textField)
                
                // Add it to the array of text fields
                textFields.append(textField)
                
                // And make sure it has no text to begin with
                textField.text = ""
                
                yOffset += 50
            case 3:
                // Creates a label for the dropdown menu
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                
                // Add it to the screen
                view.addSubview(label)
                yOffset += 10
                
                // Creates a dropdown box (I call it dropdown because I will absolutely not remember picker)
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                
                // Add it to the screen
                view.addSubview(dropdown)
                
                // Add it to the array of dropdowns
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
                
                // Add it to the screen
                view.addSubview(label)
                yOffset += 10
                
                // Create the dropdown menu
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                
                // Add it to the screen
                view.addSubview(dropdown)
                
                // Add it to the array of dropdown menus
                dropdowns.append(dropdown)
                yOffset += 10
            
                // Creates the display label below
                let subLabel = UILabel()
                subLabel.numberOfLines = 0
                
                // Ensure the subLabel can hold that many characters in size
                subLabel.text = "__________________________________________________________________________________________________________________________________________________"
                subLabel.frame = CGRect(x: 10, y: yOffset + 160, width: view.frame.width - 40, height: 20)
                subLabel.sizeToFit()
                
                // Add it to the screen
                view.addSubview(subLabel)
                yOffset += (subLabel.frame.height + 10)
                
                yOffset += 200
                
                // Initialise the subLabel
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
                
                // Okay so this code above is for one specific purpose
                // It initialises a dropdown menu with a label above it to explain what it's about
                // It then creates a label below the dropdown menu that is linked to the dropdown menu
                // Quite simply, you select an option from the dropdown menu and the label below displays certain text for that option
                // I plan on using this after the player makes some analysis request
                // So they might say "find me the best 5 players using these stats criterions, and place those 5 players into these 5 positions"
                // And then my code goes "Okay, here's a dropdown menu with 5 elements, each titled with the position title. Select it and see what players got chosen and why"
            case 6:
                // Table View
                
                // Create table
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                
                // Add it to the screen
                view.addSubview(tableView)
                yOffset += 180
                
                // Dropdown label
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                
                // Add it to the screen
                view.addSubview(label)
                yOffset += 30

                // Dropdown
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 100)
                dropdown.tag = dropdowns.count // to identify in delegate
                
                // Add it to the screen
                view.addSubview(dropdown)
                dropdowns.append(dropdown)
                yOffset += 110
                
                // Text Field
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                
                // Add it to the screen
                view.addSubview(textField)
                
                // Add it to the array of text fields
                textFields.append(textField)
                
                yOffset += 50

                // Refresh selection state
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
            case 7:
                // Create table
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                
                // Add it to the screen
                view.addSubview(tableView)
                yOffset += 160
                
                // Create Label for Dropdown
                let label = UILabel()
                label.text = "Select \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                
                // Add it to the screen
                view.addSubview(label)
                yOffset += 30

                // Dropdown
                let dropdown = UIPickerView()
                dropdown.delegate = self
                dropdown.dataSource = self
                dropdown.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 100)
                dropdown.tag = dropdowns.count // to identify in delegate
                
                // Add it to the screen
                view.addSubview(dropdown)
                
                // Add it to the array of dropdowns
                dropdowns.append(dropdown)
                yOffset += 110

                // Refresh selection state
                pickerView(dropdown, didSelectRow: 0, inComponent: 0)
            case 8:
                // Create Table
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                
                // Add it to the screen
                view.addSubview(tableView)
                yOffset += 160

                // Create Text Field
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                textField.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                textField.text = ""
                
                // Add it to the array of text fields
                textFields.append(textField)
                
                // Add it to the screen
                view.addSubview(textField)
                yOffset += 50
                
                // Creates button for adding the textField elements to the table view
                let button = createButton(with: "Add \(title)", action: #selector(addTableValues(_:)), color: .systemBlue)
                button.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                button.tag = identifier
                
                // Add it to the screen
                view.addSubview(button)
                
                // Handle using numkeys for button
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
                
                // Creates button for removing the last element from the table
                let button2 = createButton(with: "Remove \(title)", action: #selector(removeTableValues(_:)), color: .systemBlue)
                button2.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 40)
                button2.tag = identifier
                
                // Add it to the screen
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
            case 9:
                yOffset += 30
                // Label
                let label = UILabel()
                label.text = "     \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                
                // Add it to the screen
                view.addSubview(label)
                yOffset += 30
                
                // Table View
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                
                // Add it to the screen
                view.addSubview(tableView)
                yOffset += 240
            case 10: break
            default:
                break
            }
        }
    }
    
    // Takes a user input of a selected element in a dropdown, and finds the value associated with that element
    func getSelectedValue() -> String {
        let statIndex = contentManager.selectedDropdownIndex
        return contentManager.tableValues[statIndex].value
    }
    
    // Creates a button from an input
    func createButton(with title: String, action: Selector, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.5)
        return button
    }

    // MARK: - PickerView DataSource & Delegate   (IDK HOW THESE WORK BUT THEY DO)
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

    // This code lets you select an element in a dropdown, and it fills a text field with the associated value
    func updateTextFieldWithSelectedValue() {
        let index = contentManager.selectedDropdownIndex
        
        // Make sure it's a valid index otherwise the app will kill itself
        guard index < contentManager.tableValues.count else { return }
        
        // Get the value at that relevant index
        let selectedValue = contentManager.tableValues[index].value
        
        // Find the first Text Field in the view (assuming there's only one relevant one)
        for subview in view.subviews {
            
            // tf is short for text field
            if let tf = subview as? UITextField {
                
                // Set the text field's text to the value from the dropdown selection
                tf.text = selectedValue
                
                // Okay so idk much about this section, but for some reason when I was coding this function one morning in english class, the entire code was just breaking, and then I removed the version of this from the initial declaration or something and then added it here and it just worked and so I'm not going to question it and just keep it here
                if tf.allTargets.isEmpty {
                    tf.addTarget(self, action: #selector(updateTableValue(_:)), for: .editingChanged)
                }
                break
            }
        }
    }

    // This function runs when a text field is edited and that text field is linked to a tableView value
    @objc func updateTableValue(_ sender: UITextField) {
        print("updateTableValue()")
        
        // Make sure that we're trying to edit an actual existing value
        let index = contentManager.selectedDropdownIndex
        guard index < contentManager.tableValues.count,
              let newText = textFields[0].text else { return }
        
        // Update the value in the tuple while preserving title and type
        let (title, _) = contentManager.tableValues[index]
        
        // Get the text from the top of the screen (I know it's going to be [0] because my code has no elements in the view until I add the basic text
        let label = view.subviews[0] as! UILabel
        
        // Now, for five very specific text fields, when you're inputting statistic values, the values must be Floats, so MAKE SURE TO ADD TO THIS IF STATEMENT WHEN YOU NEED ONLY NUMBERS TO BE INPUT
        if label.text == "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use." || label.text == "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use." || label.text == "Edit the base values using the below text field" || label.text == "Please add any basic statistic values to the new statistics." || label.text?.components(separatedBy: " ").contains("event") == true {
            
            // So basically it checks if the text can be turned into a float. If it can then no problems
            if let _: Float = Float(newText) {
                contentManager.tableValues[index] = (title, newText)
                
            // If it can't then remove the most recent text input from the text field
            } else {
                var newText: String = textFields[0].text!
                if newText != "" {
                    newText.removeLast()
                    textFields[0].text = newText
                    
                    // Now, my code will break if you copy paste text into the text field, since it only removes the last character
                    // But if you do copy paste into the text field then you're clearly not trying to use my application for a good reason
                    // And I just don't care about you running into some slight issues
                }
            }
        
        // If it's not one of the two important Float cases then just let the text change
        } else {
            contentManager.tableValues[index] = (title, newText)
        }
        
        
        // Reload the table view to reflect the changes
        if let tableView = view.viewWithTag(999) as? UITableView {
            tableView.reloadData()
        }
    }
    
    // This function is for adding input text field values into a table
    @objc func addTableValues(_ sender: UIButton) {
        print("addTableValues()")
        
        // The table will be [1] since the creation order goes "Top Text -> ***Table*** -> Text Field -> Button"
        let table = view.subviews[1] as! UITableView
        
        // The text field will be [2] since the creation order goes "Top Text -> Table -> ***Text Field*** -> Button"
        let text = view.subviews[2] as! UITextField
        
        // If there is a proper text input
        if text.text! != "" {
            let label = view.subviews[0] as! UILabel
            
            // If this is the special case of adding new statistics to a pre-existing activity then handle duplicates
            if label.text == "Please input any new statistics to this activity using the text field" {
            
                var duplicateName: Bool = false
                
                // Check each of the statistics
                for (title,_) in contentManager.tableValues {
                    
                    // If the name already is being used then don't add the new statistic
                    if title.lowercased() == text.text?.lowercased() {
                        duplicateName = true
                    }
                }
                
                let activity: Activity = user.activities[contentManager.selectedValues.activity]
                
                // Check it against the existing statistics
                for statistic in activity.overallStatistics {
                    if statistic.name.lowercased() == text.text?.lowercased() {
                        duplicateName = true
                    }
                }
                
                // If the name isn't a duplicate then add the new name
                if !duplicateName {
                    if contentManager.tableValues[0] == ("Placeholder","") {
                        contentManager.tableValues = [(title: text.text!, value: "")]
                    } else {
                        contentManager.tableValues.append((title: text.text!, value: ""))
                    }
                }
                
                
            // If there's no values then just set the value
            } else if contentManager.tableValues.isEmpty {
                contentManager.tableValues = [(title: text.text!, value: "")]
                
            // If there's a placeholder then just set the value
            } else if contentManager.tableValues[0] == ("Placeholder","") {
                contentManager.tableValues = [(title: text.text!, value: "")]
            
            // If there are just regular values
            } else {
                
                var duplicateName: Bool = false
                
                // Check each of the statistics
                for (title,_) in contentManager.tableValues {
                    
                    // If the name already is being used then don't add the new statistic
                    if title.lowercased() == text.text?.lowercased() {
                        duplicateName = true
                    }
                }
                
                // If the name isn't a duplicate then add the new name
                if !duplicateName {
                    contentManager.tableValues.append((title: text.text!, value: ""))
                }
            }
            
            // And then refresh the table
            table.reloadData()
        }
    }
    
    // This function removes values from a table
    @objc func removeTableValues(_ sender: UIButton) {
        print("removeTableValues()")
        
        // If there are values in the table then remove the last value
        if contentManager.tableValues.count >= 1 {
            let table = view.subviews[1] as! UITableView
            contentManager.tableValues.removeLast()
            
            // Refresh the table
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

    // Function that is called when a tableView position gets clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < contentManager.tableValues.count else { return }
        
        // Set the position
        contentManager.selectedDropdownIndex = indexPath.row
        
        // Update the text field
        updateTextFieldWithSelectedValue()
        
        // Update the dropdown
        updateSelectedDropdownPosition()
    }
    
    
    // Function that is called when a tableView position gets updated, and makes a dropdown move to the tapped position
    func updateSelectedDropdownPosition() {
        for subview in view.subviews {
            if subview is UIPickerView {
                let picker = subview as! UIPickerView
                picker.selectRow(contentManager.selectedDropdownIndex, inComponent: 0, animated: true)
            }
        }
    }
}
