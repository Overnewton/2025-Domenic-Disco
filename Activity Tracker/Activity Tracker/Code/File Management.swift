import Foundation

// Declare the directory url at the start of the code so it can be used in the below functons
let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

// Function to load the data from save file
func loadGameData() {
    do {
        // Declare the decoding method
        let decoder = JSONDecoder()
        
        // Get the relevant json file from the users device
        let jsonURL = URL(fileURLWithPath: "\(user.details.username)-SaveData.json", relativeTo: directoryURL)
        
        // Get the data from that json file
        let jsonData = try Data(contentsOf: jsonURL)
        
        // Based on the value we're looking at, set that specific area
        user = try decoder.decode(User.self, from: jsonData)
    } catch {
    }
}

// Function to save the data to the save file
func saveGameData() {
    
    // Calculate the current statistics so that they're saved to the file
    for activity in user.activities {
        activity.calculateCurrentStatistics()
    }
    
    // Declare the encoder
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    // Declare a basic variable for jsonData
    let jsonData = try! encoder.encode(user)
    do {
        // Turn that data into a json string
        let jsonString: String = String(data: jsonData, encoding: .utf8)!
        
        // Figure out where the relevant json file is
        let jsonURL: URL = URL(fileURLWithPath: "\(user.details.username)-SaveData.json", relativeTo: directoryURL)
        
        // Add that text to the json file
        try jsonString.write(to: jsonURL, atomically: true, encoding: .utf8)
    }
    catch {
    }
}

// Function to add a new password onto the existing passwords
func addPassword() {
    let str: String = getOldSaves() + user.details.password + "-" + user.details.username + ","
    let filename = URL(fileURLWithPath: "saveStates.csv", relativeTo: directoryURL)
        do {
           try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
           print("file was successfully exported")

           }
        catch {

    print("file could not be exported")

    }
}

// Function to get the current saved account details of all accounts
func getOldSaves() -> String {
    let filename = URL(fileURLWithPath: "saveStates.csv", relativeTo: directoryURL)
    do {
        let data = try Data(contentsOf: filename)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        return ""
    } catch {
        return ""
    }
}

// Function to check if a password and username input is correct
func acceptableAccount(input: [String]) -> Bool {
    // Get the current account details
    let values = getOldSaves().components(separatedBy: ",")
    let userIndex = input.count - 1
    
    // If there are old files
    if getOldSaves() != "" {
        
        // Run through each input
        for user in values {
            if user != "" {
                // If the username is the same then don't let them use the name
                let userValues: [String] = user.components(separatedBy: "-")
                if userValues[1] == input[userIndex] {
                    return false
                }
            }
        }
    }
    return true
}

// Function to check if we have save data yet
func existingFiles() -> Bool {
    let filename = URL(fileURLWithPath: "saveStates.csv", relativeTo: directoryURL)
    do {
        let data = try Data(contentsOf: filename)
        if String(data: data, encoding: .utf8) != nil && String(data: data, encoding: .utf8) != "" && String(data: data, encoding: .utf8) != "," {
            return true
        }
    } catch {
        return false
    }
    return false
}

// Function to get the passwords and usernames that already exist
func getPasswords() -> [(String,String)] {
    var returnArray: [(String,String)] = []
    let baseString: String = getOldSaves()
    let users: [String] = baseString.components(separatedBy: ",")
    for user in users {
        if user != "" {
            let aspects: [String] = user.components(separatedBy: "-")
            let password: String = aspects[0]
            let username: String = aspects[1]
            returnArray.append((password,username))
        }
    }
    return returnArray
}

// Function to give a list of the current account usernames
func presentCurrentSaves() -> [String] {
    var returnArray: [String] = []
    let savedStates: [User] = bulkGetStates()
    for player in savedStates {
        returnArray.append(player.details.username)
    }
    return returnArray
}

// Function to get get the past saved usernames and passwords from the save file
func bulkGetStates() -> [User] {
    var userStates: [User] = []
    let currentUsers: [(String,String)] = getPasswords()
    for (password,username) in currentUsers {
        userStates.append(loadCustomData(password,username))
    }
    return userStates
}

// Function to create a temporary user account from the 
func loadCustomData(_ password: String, _ username: String) -> User {
    var returnUser: User = User(activities: [], details: UserDetails(username: "", password: ""), playerCount: 0, groupCount: 0, teamCount: 0)
    // Declare the decoding method
    let decoder = JSONDecoder()
    
    // Get the relevant json file from the users device
    let jsonURL = URL(fileURLWithPath: "\(username)-SaveData.json", relativeTo: directoryURL)
    
    // Get the data from that json file
    do {
        returnUser = try decoder.decode(User.self, from: try Data(contentsOf: jsonURL))
    } catch {
        
    }

    return returnUser
}

func checkSaveFile() {
    let saveFileURL = URL(fileURLWithPath: "saveStates.csv", relativeTo: directoryURL)

    if !FileManager.default.fileExists(atPath: saveFileURL.path) {
        let initialContent = "," // or whatever default content you need
        do {
            try initialContent.write(to: saveFileURL, atomically: true, encoding: .utf8)
        } catch {
        }
    }
}

func resetData() {
    contentManager = ContentManager(currentOptions: [(-20, "Begin Program", 1)], currentDisplay: "", currentTitle: "Start Application", savedTextfieldInformation: [], savedIntegers: [], savedDropdownInformation: 0, displaySeperate: [], repeatedString: "", returnPoint: 0, exitString: "", storedDropdowns: [], savedText: [], selectedValues: StoredActivity(activity: -1, team: -1, group: -1, player: -1, search: -1), tableValues: [], selectedDropdownIndex: 0, selectedRow: 0)
    user = User(activities: [], details: UserDetails(username: "", password: ""), playerCount: 0, groupCount: 0, teamCount: 0)
}

func clearSave() {
    // Clear the saveStates.csv file
    let strings: [String] = getOldSaves().components(separatedBy: ",")
    var str: String = ""
    for string in strings {
        if string != "\(user.details.password)-\(user.details.username)" {
            str += ",\(string)"
        }
    }
    
    let filename = URL(fileURLWithPath: "saveStates.csv", relativeTo: directoryURL)
        do {
           try str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
           print("file was successfully exported")

           }
        catch {

    print("file could not be exported")

    }

    // Delete related JSON files
    let fileURL = URL(fileURLWithPath: "\(user.details.username)-SaveDaa.json", relativeTo: directoryURL)
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
        }
    }
}
