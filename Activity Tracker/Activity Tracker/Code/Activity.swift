import Foundation

var user: User = User(activities: [], details: UserDetails(username: "", password: ""))

struct User: Codable {
    var activities: [Activity]
    var details: UserDetails
    
    func quickPrint() -> String {
        return "\(details.username) - Activities: \(activities.count)"
    }
}

struct UserDetails: Codable {
    var username: String
    var password: String
}

struct Activity: Codable {
    var name: String
    var storageType: Int
    var people: [String : Person]
    var groups: [Int : String]
    var teams: [Int : String]
    var combined: StatisticHolder
    
    // Array of just the statistics with no values associated
    var overallStatistics: [Statistic]
    
    // Function to add a new person into the activity
    func addUser() -> StatisticHolder {
        var newPerson: StatisticHolder = StatisticHolder(statistics: [])
        for statistic in overallStatistics {
            newPerson.statistics.append(Statistic(name: "", value: 0, rule: []))
        }
        return newPerson
    }
    
    // Function to assign a new statistic to the activity
    mutating func addStatistic(name: String, value: Int, rule: [Calculation]) {
        var newStatistic: Statistic = Statistic(name: name, value: value, rule: rule)
        overallStatistics.append(newStatistic)
        
        for (index,(key, value)) in people.enumerated() {
            people[key]!.currentStatistics.statistics.append(newStatistic)
        }
    }
}

class Person: Codable {
    var details: PersonDetails
    var currentStatistics: StatisticHolder
    var pastPeriods: [Int : StatisticHolder]
}

struct PersonDetails: Codable {
    var group: Int
    var team: Int
}

struct StatisticHolder: Codable {
    var statistics: [Statistic]
}

struct Statistic: Codable {
    var name: String
    var value: Int
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

