import Foundation

let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

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
        }
        catch {
        }
}

func saveGameData() {
        // Declare the encoder
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        // Declare a basic variable for jsonData
        var jsonData = try! encoder.encode(user)
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

func acceptableAccount(input: [String]) -> Bool {
    var values = getOldSaves().components(separatedBy: ",")
    let userIndex = input.count - 1
    if getOldSaves() != "" {
        values.removeFirst()
        for user in values {
            if user != "" {
                let values: [String] = user.components(separatedBy: "-")
                if values[1] == input[userIndex] {
                    return false
                }
            }
        }
    }
    return true
}

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

func presentCurrentSaves() -> [String] {
    var returnArray: [String] = []
    let savedStates: [User] = bulkGetStates()
    for player in savedStates {
        returnArray.append(user.quickPrint())
    }
    return returnArray
}

func bulkGetStates() -> [User] {
    var userStates: [User] = []
    let currentUsers: [(String,String)] = getPasswords()
    for (password,username) in currentUsers {
        userStates.append(loadCustomData(password,username))
    }
    return userStates
}

func loadCustomData(_ password: String, _ username: String) -> User {
    var returnUser: User = User(activities: [], details: UserDetails(username: "", password: ""))
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
    contentManager = ContentManager(currentOptions: [(-20, "Begin Program", 1)], currentDisplay: "", savedTextfieldInformation: [], savedInteger: 0, savedDropdownInformation: 0, displaySeperate: [], repeatedString: "", returnPoint: 0, exitString: "", storedDropdowns: [], savedText: [], selectedValues: StoredActivity(activity: 0, team: 0, group: 0, player: 0), tableValues: [], selectedDropdownIndex: 0, selectedRow: 0)
    user = User(activities: [], details: UserDetails(username: "", password: ""))
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
