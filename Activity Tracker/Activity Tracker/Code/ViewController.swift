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
    var savedInteger: Int
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
var contentManager: ContentManager = ContentManager(currentOptions: [(-20, "Begin Program", 1)], currentDisplay: "", savedTextfieldInformation: [], savedInteger: 0, savedDropdownInformation: 0, displaySeperate: [], repeatedString: "", returnPoint: 0, exitString: "", storedDropdowns: [], savedText: [], selectedValues: StoredActivity(activity: -1, team: -1, group: -1, player: -1), tableValues: [], selectedDropdownIndex: 0, selectedRow: 0)

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
                
                // For each account that is saved, display it as a selectable option
                for (password,username) in getPasswords() {
                    contentManager.currentOptions.append((-19,"Load \(username)",1))
                }
                
                // Or let them make a new account
                contentManager.currentOptions.append((-16,"Create New Account",1))
            } else {
                // If no save files exist then the user must make a new account
                contentManager.currentDisplay = "Hello! Please create an account so that you can use this application!"
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
            for (password,username) in getPasswords() {
                if username == sendString {
                    contentManager.currentDisplay = "This account requires a password to log in, would you like to access it?"
                    user.details.username = sendString
                    contentManager.currentOptions = [(-18,"Yes",1),(-20,"No",1)]
                    break
                }
            }
            
        case -18: // Password Entry -> Has the user login to the program by inputting the password
            contentManager.currentDisplay = "Please enter the password"
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
                        
                        // Reset stored values
                        clearTextFieldData()
                        
                        // Load the save data
                        loadGameData()
                        
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
                contentManager.currentOptions = [(0,"Password",2),(-17,"Input Data",1),(-20,"Exit Menu",1)]
            }
            
        case -16: // Account Creation -> Have the user input a username/password for new account
            contentManager.currentDisplay = "Please input your details"
            contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Input Data",1)]
            clearTextFieldData()
            
        case -15: // Create Account Confirmation
            
            // Check if the users username and password work with the program
            if acceptableAccount(input: contentManager.savedTextfieldInformation) {
                
                // Check if they contain "-" cause my CSV file stores the accounts as "Username-Password", so if they had "-" it would break my code
                if contentManager.savedTextfieldInformation[1].localizedStandardContains("-") {
                    contentManager.currentDisplay = "Unfortunately my program doesn't allow for '-' to be placed within usernames or passwords, I'm very sorry for the inconvenience but please change your input."
                    contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1),(-20,"Exit Menu",1)]
                    clearTextFieldData()
                } else {
                    
                    // Make sure that neither the username or the password are blank since that might also break my code. Not sure if it would, but I just don't want to deal with it
                    if contentManager.savedTextfieldInformation.contains("") {
                        contentManager.currentDisplay = "Unfortunately my program doesn't allow for ' ' to be used as usernames or passwords, I'm very sorry for the inconvenience but please change your input."
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
                        contentManager.currentOptions = [(-14,"Begin Application Tutorial",1)]
                    }
                }
                
            // Check if the username is already in use cause I also can't be bothered to handle two accounts with the same username but different passwords
            } else {
                contentManager.currentDisplay = "Unfortunately that username is already in use, please select a different one"
                contentManager.currentOptions = [(0,"Password",2),(0,"Username",2),(-15,"Submit Data",1)]
                clearTextFieldData()
            }
            
        case -14: // Tutorial Text 1 -> Text explaining how to use my app
            contentManager.currentDisplay = "Hello my dear user, I'm Domenic Disco, the creator of this application that you are using.\n\nI'm assuming that you know what the app is about, but if you don't, it's a method of storing players and sorting for a given activity of any type"
            contentManager.currentOptions = [(-13,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -13: // Tutorial Text 2 -> Text explaining how to use my app
            contentManager.currentDisplay = "You could store any kind of activity, maybe board game statistics, league of legends, mario kart race times, basketball player statistics. You could even go as far as storing student grades within this application, since it's perfect for storing and sorting any kind of statistics for a group or collection of people"
            contentManager.currentOptions = [(-12,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -12: // Tutorial Text 3 -> Text explaining how to use my app
            contentManager.currentDisplay = "Now, how do you use my application?\n\nFirst, you create an activity. This will be done in a 3 step procedure.\n\n1 - Add the activity name, just input it into a text field and press a button to confirm\n\n2 - Add the activities statistics, type the statistic name into a text field, select it's type in a dropdown menu, and then press a button to add it\n\n3 - Add any base values for statistics, you select a statistic using a dropdown menu, and then input the basic value into the text field below.\n\nAnd that's all it takes, just do those 3 steps and you'll have an activity!"
            contentManager.currentOptions = [(-11,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -11:  // Tutorial Text 4 -> Text explaining how to use my app
            contentManager.currentDisplay = "But just having an activity isn't enough, you need to have some players otherwise there's not much point to the application. To make players, you follow another easy 3 step procedure\n\n1 - Add the players name, once again in a text field\n\n2 - Set the players statistics using the same method as setting basic statistics for an activity\n\n3 - Then you can decide if you want the player to be part of a team or group, allowing them to be more easily sorted.\n\nAnd that's all it needs, just 3 easy steps and you can fill up your activity with any player you'd need!"
            contentManager.currentOptions = [(-10,"Next",1),(-2,"Skip Tutorial",1)]
            
        case -10:  // Tutorial Text 5 -> Text explaining how to use my app
            contentManager.currentDisplay = "And that's all you'll need to use my program! There are some complicated features later on, such as my sorting and searching algorithms, but those will be covered when you get to them. No reason to overcomplicate you experience right now.\n\nGood luck with your storing and managing of activities!"
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
            contentManager.currentOptions = [(1,"View Activities",1),(0,"Modify System Settings",1),(0,"Log Out",1)]
            saveGameData()
        case 1: // View Activities
            contentManager.savedTextfieldInformation = []
            
            // If user has no activities then tell them to make activity
            if user.activities.isEmpty {
                contentManager.currentDisplay = "You currently don't have any activites, to create a new activity press 'Create New Activity'"
                contentManager.currentOptions = [(2,"Create New Activity",1),(0,"Exit",1)]
            
            // Otherwise display activities and let them select
            } else {
                contentManager.currentDisplay = "Please select the activity that you want to view using the dropdown menu. Or press 'Create New Activity' to create a new activity."
                contentManager.currentOptions = [(0,"Activity",7),(7,"View Activity",1),(2,"Create New Activity",1)]
                
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
            contentManager.currentOptions = [(0,"Activity Name", 2),(3,"Create Activity",1), (1,"Exit Menu",1)]
        case 3: // Assign Activity Name --- Add Activity Statistics
            // Check that they did input a name
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give an activity the name of ''. That would just not work with the rest of my code. Please give it an actual name"
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
                    contentManager.currentOptions = [(2,"Exit",1)]
                
                // If the name isn't already used, then let them input the statistics for that activity
                } else {
                    contentManager.currentDisplay = "Please input the statistics that will be used for activity \(contentManager.savedTextfieldInformation[0]).\n\nTo do this, write down the statistic name in the text field, and then exit the text field to add it to the table."
                    contentManager.currentOptions = [(0,"Statistic",8),(4,"Finalise Statistics",1),(1,"Exit Menu",1)]
                    contentManager.tableValues = [("Placeholder","")]
                }
            }
        case 4: // Adding Values
            contentManager.currentDisplay = "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use."
            contentManager.currentOptions = [(0,"Statistic",6), (5,"Finalise Statistics",1), (1,"Exit Menu",1)]
            
            // Set all values to start with 0 as the basic
            for (index,_) in contentManager.tableValues.enumerated() {
                contentManager.tableValues[index].value = "0"
            }
        case 5: // Select Activity Type
            contentManager.currentDisplay = "This activity can be further customised. You have three choices for what type of activity you want it to be:\n\nOption 1 - The activity will have both groups and teams, meaning you can split up players two seperate times, such as age group and then by division.\n\nOption 2 - The activity will have teams, meaning you can split players up based on just one category like division or age group.\n\nOption 3 - The activity won't have groups or teams, instead just stores all the players together.\n\nWhich method would you like to use?\n"
            contentManager.currentOptions = [(6,"Option 1",1),(6,"Option 2",1),(6,"Option 3",1),(1,"Exit Menu",1)]
        case 6: // Finalise Activity Creation
        
            contentManager.currentDisplay = "Congratulations, you have successfully created the activity \(contentManager.savedTextfieldInformation[0]). This activity has \(contentManager.tableValues.count) statistics being tracked, and uses player storage Option \(sender.titleLabel!.text!.last!)"
            // Create Activity Here
            var newActivity: Activity = Activity(name: contentManager.savedTextfieldInformation[0], storageType: 0, people: [], groups: [], teams: [], combined: StatisticHolder(description: "Overall Statistics", statistics: []), overallStatistics: [])
            
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
            
            // Based on whether the activity has teams and groups, decide what options to give to the user
            switch useActivity.storageType {
            case 1: contentManager.currentOptions = [(21,"View Activity Details",1), (12,"View All Players",1), (8,"View Groups",1), (10,"View Teams",1), (1,"Exit Menu",1)]
            case 2: contentManager.currentOptions = [(21,"View Activity Details",1), (12,"View All Players",1), (10,"View Teams",1), (1,"Exit Menu",1)]
            case 3: contentManager.currentOptions = [(21,"View Activity Details",1), (12,"View All Players",1), (1,"Exit Menu",1)]
            default: break
            }
        case 8: // Select Group
            // Reset the team and player values to avoid later issues
            contentManager.selectedValues.team = -1
            contentManager.selectedValues.player = -1
            
            // Get the activity as it's own constant for ease of use
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // If no groups exist then have the user make a new group
            if activity.groups.isEmpty {
                contentManager.currentDisplay = "You currently don't have any groups, to create a new group press 'Create New Group'"
                contentManager.currentOptions = [(23,"Create New Group",1),(7,"Exit",1)]
            
            // Otherwise display groups and let them select
            } else {
                contentManager.currentDisplay = "Please select the group that you want to view using the dropdown menu. Or press 'Create New Group' to create a new group."
                contentManager.currentOptions = [(0,"Group",7),(9,"View Group",1),(2,"Create New Group",1),(7,"Exit Menu",1)]
                
                // Set the table view to show groups and set the dropdown to match the tableview
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for group in activity.groups {
                    contentManager.tableValues.append((group.name,""))
                    contentManager.storedDropdowns.append(group.name)
                }
            }
        case 9: // View Group
            // Set the selected group to whichever value the user selected in the dropdown menu
            contentManager.selectedValues.group = contentManager.savedDropdownInformation
            
            // Save data since some later cases send the user back here
            saveGameData()
            
            // MARK: AAAAA
            // WORK IN PROGRESS, DISPLAY THE GROUP HERE, ADD A OPTION TO VIEW PLAYERS FOR GROUP, ADD A OPTION TO DELETE GROUP, ETC
            contentManager.currentDisplay = "View Group Screen -> Set text here"
            contentManager.currentOptions = [(7,"Exit Menu",1)]
            
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
                contentManager.currentDisplay = "Select Team Screen"
                contentManager.currentOptions = [(7,"Exit Menu",1)]
            
            // Otherwise let the user select the team
            } else {
                contentManager.currentDisplay = "Select Team Screen"
                contentManager.currentOptions = [(7,"Exit Menu",1)]
                
                // Display the players names in the tableValues
                contentManager.tableValues = []
                contentManager.storedDropdowns = []
                for team in useTeams {
                    contentManager.tableValues.append((team.name,""))
                    contentManager.storedDropdowns.append(team.name)
                }
            }
            
        case 11: // View Team
            saveGameData()
            
            // Reset viewed player value
            contentManager.selectedValues.player = -1
            
            // Set the team that we're viewing to what the player selected
            if sender.titleLabel!.text == "View Team" {
                contentManager.selectedValues.team = contentManager.savedDropdownInformation
            }
            
            // Get the team that we're meant to be viewing
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Get the team that we're displaying
            var team: Team?
            
            // Figure out what team to get
            if contentManager.selectedValues.group != -1 {
                let group: Group = activity.groups[contentManager.selectedValues.group]
                team = group.teams[contentManager.selectedValues.team]
            } else {
                team = activity.teams[contentManager.selectedValues.team]
            }
            
            contentManager.currentDisplay = "View Team Screen"
            contentManager.currentOptions = [(7,"Exit Menu",1)]
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
            default: break
            }
            
            // If no people are in the array then have the user add a new player
            if displayPeople.isEmpty {
                contentManager.currentDisplay = "Currently your selection doesn't have any players, to create a new player, press 'Add New Player'"
                contentManager.currentOptions = [(13,"Add New Player",1),(7,"Exit",1)]
            } else {
                // Otherwise let them select the player they want to view
                contentManager.currentDisplay = "Please select the player that you want to view using the dropdown menu. Or press 'Add New Player' to input a new player."
                contentManager.currentOptions = [(0,"Player",7), (22,"View Player",1), (13,"Add New Player",1), (7,"Exit",1)]
                
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
            contentManager.currentOptions = [(0,"Name",2),(14,"Submit Name",1),(7,"Exit Menu",1)]
            clearTextFieldData()
        case 14: // Create Player -> Check Name / Add Statistics
            // Check that name isn't blank
            if contentManager.savedTextfieldInformation[0] == "" {
                contentManager.currentDisplay = "Unfortunately, you cannot give a player a blank name. That would just not work with the rest of my code. Please give them an actual name"
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
                    contentManager.currentOptions = [(13,"Exit",1)]
                } else {
                    // Otherwise, let the user decide whether to input some base statistics or not
                    contentManager.currentDisplay = "Within my application, the players that you create are able to hold statistics from a given period of time, such as from a match or a training or any kind of event\n\nIf you have one singular events data to input, then please press 'Input Statistics'.\n\nHowever, if you either don't have any statistics or have more than one events worth of statistics, please press 'Input Player', and add the statistics in later."
                    
                    contentManager.currentOptions = [(16,"Input Statistics",1), (15,"Input Player",1)]
                    contentManager.tableValues = [("Placeholder","")]
                }
            }
            
        case 15: // Input Player
            contentManager.currentDisplay = "If you are 100% certain about inputting this player to your activity, please press 'Input Player', otherwise please press 'Exit Menu'"
            contentManager.currentOptions = [(17,"Input Player",1), (7,"Exit Menu",1)]
            
        case 16: // Input Player Statistics While Creating
            contentManager.currentDisplay = "Please enter the statistics for player \(contentManager.savedTextfieldInformation[0]) using the text field."
            contentManager.currentOptions = [(0,"Statistic",6),(17,"Finalise Statistics",1)]
            
            // Have the tableview show all of the players statistics, with their basic values
            contentManager.tableValues = []
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            for statistic in activity.overallStatistics {
                contentManager.tableValues.append((title: statistic.name, value: String(statistic.value)))
            }
            
        case 17: // Player Created
            contentManager.currentDisplay = "The new player, \(contentManager.savedTextfieldInformation[0]), has successfully been created!"
            
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            // Create the player
            let newPlayer: Person = Person(details: PersonDetails(name: contentManager.savedTextfieldInformation[0], uniqueID: user.playerCount, group: FixedStorage(index: -1, name: "", id: -1), team: FixedStorage(index: -1, name: "", id: -1)), currentStatistics: StatisticHolder(description: "Current", statistics: []), pastPeriods: [:])
            user.playerCount += 1
            
            // If the player is being created with stats then do that here
            if !contentManager.tableValues.isEmpty {
                for (index,(title,value)) in contentManager.tableValues.enumerated() {
                    
                    var statistic: Statistic = activity.overallStatistics[index]
                    if value != "" {
                        statistic.value = Float(value)!
                    }
                    newPlayer.currentStatistics.statistics.append(statistic)
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
                
                // Update the players details
                team.people.append(newPlayer)
                newPlayer.details.getFrom(team)
            }
            
            saveGameData()
            
            contentManager.currentOptions = [(7,"Exit Menu",1)]
        case 18: break
        case 19: break
        case 20: break
        case 21: // View Activity Details
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            contentManager.currentDisplay = "Activity: \(activity.name)"
            contentManager.currentOptions = [(0,"Statistics",9),(7,"Exit Menu",1)]
            contentManager.tableValues = []
            for statistic in activity.overallStatistics {
                contentManager.tableValues.append((title: statistic.name,value: String(statistic.value)))
            }
        case 22:
            let activity: Activity = user.activities[contentManager.selectedValues.activity]
            
            contentManager.currentDisplay = "View Player"
            contentManager.currentOptions = [(7,"Exit Menu",1)]

            Person(details: PersonDetails(name: contentManager.savedTextfieldInformation[0], uniqueID: user.playerCount, group: FixedStorage(index: -1, name: "", id: -1), team: FixedStorage(index: -1, name: "", id: -1)), currentStatistics: StatisticHolder(description: "Current", statistics: []), pastPeriods: [:])
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
    
    func clearTextFieldData() {
        contentManager.savedTextfieldInformation = []
    }
    
    func saveTextFieldData() {
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
                textField.text = ""
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
                yOffset += 240
                
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
            case 9:
                yOffset += 30
                // Label
                let label = UILabel()
                label.text = "     \(title):"
                label.frame = CGRect(x: 10, y: yOffset, width: view.frame.width - 40, height: 20)
                view.addSubview(label)
                yOffset += 30
                
                // Table View
                let tableView = UITableView()
                tableView.delegate = self
                tableView.dataSource = self
                tableView.frame = CGRect(x: 20, y: yOffset, width: view.frame.width - 40, height: 150)
                tableView.tag = 999  // arbitrary tag to find later
                view.addSubview(tableView)
                yOffset += 240
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
        print("updateTextFieldWithSelectedValue()")
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
        print("updateTableValue()")
        let index = contentManager.selectedDropdownIndex
        guard index < contentManager.tableValues.count,
              let newText = textFields[0].text else { return }
        
        // Update the value in the tuple while preserving title and type
        let (title, value) = contentManager.tableValues[index]
        
        let label = view.subviews[0] as! UILabel
        
        if label.text == "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use." || label.text == "Please add any basic statistic values to this activity, such as points scores starting at 0, or whatever initial values you want to use." {
            if let _: Float = Float(newText) {
                contentManager.tableValues[index] = (title, newText)
            } else {
                var newText: String = textFields[0].text!
                if newText != "" {
                    newText.removeLast()
                    textFields[0].text = newText
                }
            }
        } else {
            contentManager.tableValues[index] = (title, newText)
        }
        
        
        // Reload the table view to reflect changes
        if let tableView = view.viewWithTag(999) as? UITableView {
            tableView.reloadData()
        }
    }
    
    @objc func addTableValues(_ sender: UIButton) {
        print("addTableValues()")
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
        print("removeTableValues()")
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
