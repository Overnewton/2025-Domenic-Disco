import Foundation

var user: User = User(activities: [], details: UserDetails(username: "", password: ""), playerCount: 0)

struct User: Codable {
    var activities: [Activity]
    var details: UserDetails
    var playerCount: Int
    
    func quickPrint() -> String {
        return "\(details.username) - Activities: \(activities.count)"
    }
}

struct UserDetails: Codable {
    var username: String
    var password: String
}

class Activity: Codable {
    var name: String
    var storageType: Int
    var people: [Person]
    var groups: [Group]
    var teams: [Team]
    var combined: StatisticHolder
    
    // Array of just the statistics with no values associated
    var overallStatistics: [Statistic]
    
    // Function to assign a new statistic to the activity
    func addStatistic(name: String, value: Float, rule: [Calculation]) {
        let newStatistic: Statistic = Statistic(name: name, value: value, rule: rule)
        overallStatistics.append(newStatistic)
        
        for (index,person) in people.enumerated() {
            people[index].currentStatistics.statistics.append(newStatistic)
        }
    }
    
    init(name: String, storageType: Int, people: [Person], groups: [Group], teams: [Team], combined: StatisticHolder, overallStatistics: [Statistic]) {
        self.name = name
        self.storageType = storageType
        self.people = people
        self.groups = groups
        self.teams = teams
        self.combined = combined
        self.overallStatistics = overallStatistics
    }
}

// Used to hold groups of people within an activity
// Can hold further teams within the group
class Group: Codable {
    var name: String // Group name
    var people: [Person] // The people in the group
    var teams: [Team] // The teams within the group
    var uniqueID: Int
    
    init(name: String, people: [Person], teams: [Team], uniqueID: Int) {
        self.name = name
        self.people = people
        self.teams = teams
        self.uniqueID = uniqueID
    }
}

// Used to hold teams of people within an activity
// Cannot hold further groups within the team
class Team: Codable {
    var name: String // Team name
    var people: [Person] // The people in the team
    var uniqueID: Int
    
    init(name: String, people: [Person], uniqueID: Int) {
        self.name = name
        self.people = people
        self.uniqueID = uniqueID
    }
}

// This is a fixed storage struct, used to ensure no data irregularities exist
// This records an index within an array, and it's name, so that if for some reason they shift up or down 1 slot in the array, I have this kinda 2 step process where I confirm that both the index and the names match

// Example Use : The player is in team 3, which is in index slot 2 of the Teams array
// If team 2 gets removed, team 3 moves to index slot 1 which now means that any values that refer to team 3 as index slot 2 are now out of whack
// Unsure about where specifically this could occur, or what problems it may bring to my code, but this Fixed Storage system is just there to make sure that if problems do pop up later in my code, that I can handle them much easier without any code refactoring
struct FixedStorage: Codable {
    var index: Int
    var name: String
    var id: Int
}

class Person: Codable {
    var details: PersonDetails
    var currentStatistics: StatisticHolder
    var pastPeriods: [Int : StatisticHolder]
    
    init(details: PersonDetails, currentStatistics: StatisticHolder, pastPeriods: [Int : StatisticHolder]) {
        self.details = details
        self.currentStatistics = currentStatistics
        self.pastPeriods = pastPeriods
    }
    
    // Function to display a player
    func display() -> String {
        
        // Get the text to describe their group
        var groupText: String = ""
        if contentManager.selectedValues.group != -1 {
            
            // If they start their name with "group" then don't add a second group to it
            if details.group.name.components(separatedBy: " ")[0].lowercased() == "group" {
                groupText = "They are in \"\(details.group.name)\""
            } else {
                groupText = "They are in the group \"\(details.group.name)\""
            }
            groupText += "\n"
        }
        
        // Get the text to describe their team
        var teamText: String = ""
        if contentManager.selectedValues.team != -1 {
            
            // If they start their name with "team" then don't add a second team to it
            if details.team.name.components(separatedBy: " ")[0].lowercased() == "team" {
                teamText = "They are in \"\(details.team.name)\""
            } else {
                teamText = "They are in the team \"\(details.team.name)\""
            }
            teamText += "\n"
        }
        
        var doubleCheck: String = ""
        if pastPeriods.count != 1 {
            doubleCheck = "s"
        }
        
        // Return the values
        return """
        You are currently viewing \(details.name), a member of the \(user.activities[contentManager.selectedValues.activity].name) activity.
        \(groupText)\(teamText)
        They currently have \(pastPeriods.count) data input\(doubleCheck)
        """
    }
}

struct PersonDetails: Codable {
    var name: String
    var uniqueID: Int
    var group: FixedStorage
    var team: FixedStorage
    
    // Function to set the players group and team details by inputting either a group or team
    mutating func getFrom(_ input: Any) {
        
        // If the input is an array then run this code for each of the values
        if input is [Any] {
            for value in (input as! [Any]) {
                self.getFrom(value)
            }
            
        // If the input is a group, set the players group id and index
        } else if input is Group {
            let addGroup = input as! Group
            group.id = addGroup.uniqueID
            group.index = contentManager.selectedValues.group
        
        // If the input is a team, set the players team id and index
        } else if input is Team {
            let addTeam = input as! Team
            team.id = addTeam.uniqueID
            team.index = contentManager.selectedValues.team
        }
    }
}

struct StatisticHolder: Codable {
    var description: String
    var statistics: [Statistic]
}

struct Statistic: Codable {
    var name: String
    var value: Float
    var rule: [Calculation]
}

extension [Statistic] {
    func searchNamesFor(input: String) -> Int {
        for (index,statistic) in self.enumerated() {
            if statistic.name == input {
                return index
            }
        }
        return -1
    }
}


extension String {
    func toClassification() -> StatisticClass {
        switch self {
        case "calculated": return .calculated
        case "permanent": return .permanent
        case "input": return .input
        default: return .input
        }
    }
}


enum StatisticClass: Codable {
    case calculated, permanent, input
}

// A class used to store automatic calculations for variables
class Calculation: Codable {
    // Stores the first variable
    var primaryTerm: String
    var operation: Operation
    var secondaryTerm: String
    
    init(primaryTerm: String, operation: Operation, secondaryTerm: String) {
        self.primaryTerm = primaryTerm
        self.operation = operation
        self.secondaryTerm = secondaryTerm
    }
    
    func run(inputPerson: StatisticHolder) -> Float {
        // Declare the two values to work with
        var primaryValue: Float?
        var secondaryValue: Float?
        
        // Get the value of the statistic index we should be looking at
        let pv: Int = inputPerson.statistics.searchNamesFor(input: primaryTerm)
        let sv: Int = inputPerson.statistics.searchNamesFor(input: secondaryTerm)
        
        // If the above code failed to find an index
        if pv == -1 {
            
            // Check if the value being stored was actually just a number
            if (Float(primaryTerm) != nil) {
                primaryValue = Float(primaryTerm)!
            }
        } else {
            // If it did work, then get the value
            primaryValue = inputPerson.statistics[pv].value
        }
        
        // If the above code failed to find an index
        if sv == -1 {
            
            // Check if the value being stored was actually just a number
            if (Float(secondaryTerm) != nil) {
                secondaryValue = Float(secondaryTerm)!
            }
        } else {
            // If it did work, then get the value
            secondaryValue = inputPerson.statistics[sv].value
        }
        
        // Get the output
        var outputValue: Float?
        
        // Perform the appropriate calculation
        switch operation {
        case .add:
            outputValue = primaryValue! + secondaryValue!
        case .subtract:
            outputValue = primaryValue! - secondaryValue!
        case .multiply:
            outputValue = primaryValue! * secondaryValue!
        case .divide:
            outputValue = primaryValue! / secondaryValue!
        }
        
        // Return the value
        return outputValue!
    }
}

// An operation means math stuff
enum Operation: Codable {
    case add, subtract, multiply, divide
}

