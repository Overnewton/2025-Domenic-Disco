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
}

struct PersonDetails: Codable {
    var name: String
    var uniqueID: Int
    var group: FixedStorage
    var team: FixedStorage
    
    // Function to set the players group and team details by inputting either a group or teamt
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

class Calculation: Codable {
    var primaryTerm: Float
    var operation: Operation
    var secondaryTerm: Float
    
    init(primaryTerm: Float, operation: Operation, secondaryTerm: Float) {
        self.primaryTerm = primaryTerm
        self.operation = operation
        self.secondaryTerm = secondaryTerm
    }
    
    func run(inputPerson: StatisticHolder) -> Float {
        var primaryValue: Float = primaryTerm
        var secondaryValue: Float = secondaryTerm
        var outputValue: Float = 0
        
        switch operation {
        case .add:
            outputValue = primaryValue + secondaryValue
        case .subtract:
            outputValue = primaryValue - secondaryValue
        case .multiple:
            outputValue = primaryValue * secondaryValue
        case .divide:
            outputValue = primaryValue / secondaryValue
        }
        
        return outputValue
    }
}

enum Operation: Codable {
    case add, subtract, multiple, divide
}

