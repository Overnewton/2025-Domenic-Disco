import Foundation

var user: User = User(activities: [], details: UserDetails(username: "", password: ""), playerCount: 0, groupCount: 0, teamCount: 0)

struct User: Codable {
    var activities: [Activity]
    var details: UserDetails
    var playerCount: Int
    var groupCount: Int
    var teamCount: Int
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
    var searchRules: [SearchRule]
    var combined: StatisticHolder
    
    // Array of just the statistics with no values associated
    var overallStatistics: [Statistic]

    // Function to get a players postion within the activity's players
    func searchPlayersFor(ID: Int) -> Int {
        // Run through all the players
        for (index,player) in people.enumerated() {
            
            // If the ID matches then return their index
            if player.details.uniqueID == ID {
                return index
            }
        }
        return -1
    }

    // Function to calculate the current total statistics of an activity
    func calculateCurrentStatistics() {
        // First reset the values to 0 so that all base values are removed
        for (index,statistic) in self.combined.statistics.enumerated() {
            self.combined.statistics[index].value = 0
        }
        
        // Run through each of the people in the activity
        for player in self.people {
            
            // Get their statistics
            for (index,statistic) in player.currentStatistics.statistics.enumerated() {
                
                // If the statistic is a pure value then add it to the overall tally
                if statistic.rule.isEmpty {
                    self.combined.statistics[index].value += statistic.value
                }
            }
        }
        
        // Run through the statistics in the activity and run the rules for them
        for (index,statistic) in self.combined.statistics.enumerated() {
            if !statistic.rule.isEmpty {
                // Run the rule to calculate the values automatically
                self.combined.statistics[index].value = statistic.rule[0].run(inputPerson: self.combined)
            }
        }
    }
    
    // Function to assign a new statistic to the activity
    func addStatistic(_ newStatistic: Statistic) {
        // Add the statistic to the activity
        overallStatistics.append(newStatistic)
        
        // Check if this statistic is an automatic calculation statistic
        if !newStatistic.rule.isEmpty {
            
            for person in people {
                // Add the statistic
                person.currentStatistics.statistics.append(newStatistic)
                
                // Run the actual operation
                person.currentStatistics.statistics[person.currentStatistics.statistics.count - 1].value = newStatistic.rule[0].run(inputPerson: person.currentStatistics)
                
                // Run through their past data and add the statistic
                for (key,_) in person.pastPeriods {
                    
                    // StatisticHolder is a struct, so I can't make this cleaner
                    person.pastPeriods[key]?.statistics.append(newStatistic)
                    
                    // Run the actual operation onto the past periods data
                    person.pastPeriods[key]?.statistics[(person.pastPeriods[key]?.statistics.count)! - 1].value = newStatistic.rule[0].run(inputPerson: person.pastPeriods[key]!)
                }
            }
        
            
        // If it isn't, then just add the statistic to the players
        } else  {
            for person in people {
                // Add the statistic
                person.currentStatistics.statistics.append(newStatistic)
            }
        }
    }
    
    init(name: String, storageType: Int, people: [Person], groups: [Group], teams: [Team], combined: StatisticHolder, overallStatistics: [Statistic], searchRules: [SearchRule]) {
        self.name = name
        self.storageType = storageType
        self.people = people
        self.groups = groups
        self.teams = teams
        self.combined = combined
        self.overallStatistics = overallStatistics
        self.searchRules = searchRules
    }
}

struct SearchRule: Codable {
    var name: String
    var rules: [String]
    var players: [Person]
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

// Class to store a person
class Person: Codable {
    var details: PersonDetails
    var currentStatistics: StatisticHolder
    var pastPeriods: [Int : StatisticHolder]
    
    init(details: PersonDetails, currentStatistics: StatisticHolder, pastPeriods: [Int : StatisticHolder]) {
        self.details = details
        self.currentStatistics = currentStatistics
        self.pastPeriods = pastPeriods
    }
    
    // Function to calculate the combined total of a persons past periods
    func calculateCurrentStatistics() {
        // First reset the values to 0 so that all base values are removed
        for (index,statistic) in self.currentStatistics.statistics.enumerated() {
            self.currentStatistics.statistics[index].value = 0
            
        }
        
        // Run through all past periods
        for (_,pastStatistics) in pastPeriods {
            
            // Get every statistic from those periods
            for (statistic) in pastStatistics.statistics {
                
                // As long as there isn't a rule for the statistic, add it to the current value
                if statistic.rule.isEmpty {
                    let statIndex: Int = currentStatistics.statistics.searchNamesFor(input: statistic.name)
                    if statIndex != -1 {
                        currentStatistics.statistics[statIndex].value += statistic.value
                    }
                }
            }
        }
        
        // Run through all the statistics for any rules
        for (index,statistic) in currentStatistics.statistics.enumerated() {
            if !statistic.rule.isEmpty {
                // Get the rule
                let calculation: Calculation = currentStatistics.statistics[index].rule[0]
                
                // Set the value using the rule
                currentStatistics.statistics[index].value = calculation.run(inputPerson: currentStatistics)
            }
        }
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

// Function that can be used on an array of statistics that gives the index of a statistic with any name
extension [Statistic] {
    func searchNamesFor(input: String) -> Int {
        
        // Run through all statistics
        for (index,statistic) in self.enumerated() {
            
            // If the names match then give the index
            if (statistic.name).lowercased() == (input).lowercased() {
                return index
            }
        }
        // If no matches are found return -1
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
    
    func toString() -> String {
        return "\(primaryTerm) \(operation.toString()) \(secondaryTerm)"
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
            // For division make sure we don't ever get a divide by 0 error
            if secondaryValue != 0 {
                outputValue = primaryValue! / secondaryValue!
            } else {
                outputValue = 0
            }
        }
        
        // Return the value
        return outputValue!
    }
}

func addTestActivities() {
    for index in 1...4 {
        user.activities.append(Activity(name: "Activity \(index)", storageType: 1, people: [], groups: [], teams: [], combined: StatisticHolder(description: "Overall", statistics: []), overallStatistics: [], searchRules: []))
        for index in 1...Int.random(in: 5...12) {
            let newStatistic: Statistic = Statistic(name: "Statistic\(index)", value: Float.random(in: 0...5000), rule: [])
            user.activities[user.activities.count - 1].overallStatistics.append(newStatistic)
        }
        for _ in 1...Int.random(in: 100...300) {
            user.activities.last!.people.append(createTestPlayer(for: user.activities.last!))
        }
    }
}

func createTestPlayer(for activity: Activity) -> Person {
    let returnPerson: Person = Person(details: PersonDetails(name: "Player \(activity.people.count)", uniqueID: user.playerCount, group: FixedStorage(index: -1, name: "", id: -1), team: FixedStorage(index: -1, name: "", id: -1)), currentStatistics: StatisticHolder(description: "Current", statistics: []), pastPeriods: [:])
    user.playerCount += 1
    
    returnPerson.currentStatistics.statistics = activity.overallStatistics
    
    for index in 1...5 {
        returnPerson.pastPeriods[index] = StatisticHolder(description: "Period \(index)", statistics: activity.overallStatistics)
        for (index2,statistic) in returnPerson.pastPeriods[index]!.statistics.enumerated() {
            if statistic.rule.isEmpty {
                returnPerson.pastPeriods[index]?.statistics[index2].value *= Float.random(in: 0.5...3)
            } else {
                let calculation: Calculation = (returnPerson.pastPeriods[index]?.statistics[index].rule[0])!
                
                returnPerson.pastPeriods[index]?.statistics[index2].value = calculation.run(inputPerson: (returnPerson.pastPeriods[index])!)
            }
        }
    }
    
    returnPerson.calculateCurrentStatistics()
    
    return returnPerson
}

// An operation means math stuff
enum Operation: Codable {
    case add, subtract, multiply, divide
    
    func toString() -> String {
        switch self {
        case .add: return "+"
        case .subtract: return "-"
        case .multiply: return "*"
        case .divide: return "/"
        }
    }
}

extension String {
    // Function to validate components of an automatic calculation
    func isValidComponent() -> Bool {
        
        // First check if the input is a number
        if self.isFloat() {
            return true
        }
        
        // Check if the input is a statistic
        if user.activities[contentManager.selectedValues.activity].overallStatistics.searchNamesFor(input: self) != -1 {
            return true
        }
        
        // If none of those worked, then the rule is a failure on this condition
        return false
    }
    
    // Function to check if a string can be turned into a float
    func isFloat() -> Bool {
        
        // If the value can be turned into a float
        if let _: Float = Float(self) {
            return true
        }
        
        return false
    }
    
    // Function to check if a string is a valid operator for an automatic calculation
    func isValidOperator() -> Bool {
        return ["+","-","/","*","x"].contains(self)
    }
    
    // Function to check if a string is a valid operator for a search function
    func isValidSearchOperator() -> Bool {
        return [">", "<", "=", "!=", ">=", "<=", "~"].contains(self)
    }
    
    // Function to check if a string is a valid operator for a sort function
    func isValidSortOperator() -> Bool {
        return [">", "<"].contains(self)
    }
    
    // Function to convert an operator symbol into a word
    func described() -> String {
        switch self {
        case "+": return "Add"
        case "-": return "Subtract"
        case "/": return "Divide"
        case "*", "x": return "Multiply"
        default: return ""
        }
    }
    
    // Function to convert an operator symbol into a word
    func toOperator() -> Operation {
        switch self {
        case "+": return .add
        case "-": return .subtract
        case "/": return .divide
        case "*", "x": return .multiply
        default: return .add
        }
    }
}

// Used to allow .lowercased() to work on arrays
extension [String] {
    func lowercased() -> [String] {
        var returnArray: [String] = []
        for value in self {
            returnArray.append(value.lowercased())
        }
        return returnArray
    }
}

extension [(String, String)] {
    func lowercased() -> [(String,String)] {
        var returnArray: [(String,String)] = []
        for (value1,value2) in self {
            returnArray.append((value1.lowercased(),value2))
        }
        return returnArray
    }
}


// Function to run a complex search using an array of rules
func runSearches(usePlayers: inout [Person], rules: [String], activity: Activity) {
    
    // Seperate the rules into sorts and searches
    var sortRules: [String] = []
    var searchRules: [String] = []
    
    // Seperate them using the first word of the string
    for value in rules {
        if value.components(separatedBy: " ")[0].lowercased() == "sort" {
            sortRules.append(value)
        } else {
            searchRules.append(value)
        }
    }
    
    // Run through each of the searches
    for rule in searchRules {
        // Get the rule into a workable form
        var ruleElements: [String] = rule.components(separatedBy: " ")
        
        // Get the indexes of the players who failed the check
        var indexArray: [Int] = []
        
        // Array for if the user uses a "~" check
        var valueArray: [(Float,Int)] = []
        
        // Run each player through the check
        for (index,player) in usePlayers.enumerated() {
            
            // Get the value that we are checking
            let statisticIndex: Int = activity.overallStatistics.searchNamesFor(input: ruleElements[1])
            let statisticValue: Float = player.currentStatistics.statistics[statisticIndex].value
            
            // Perform the opposite calculation to what the user wants, and if they pass it then they fail the actual one
            switch ruleElements[2] {
                
                // If the user wants greater than, if it's less than or equal to, then remove it
            case ">": if statisticValue <= Float(ruleElements[3])! {
                indexArray.append(index)
            }
                
                // If the user wants less than, if it's greater than or equal to, then remove it
            case "<": if statisticValue >= Float(ruleElements[3])! {
                indexArray.append(index)
            }
                
                // If the user wants equal to, if it's not equal to, then remove it
            case "=": if statisticValue != Float(ruleElements[3]) {
                indexArray.append(index)
            }
                
                // If the user wants not equal to, if it's equal to, then remove it
            case "!=": if statisticValue == Float(ruleElements[3])! {
                indexArray.append(index)
            }
                
                // If the user wants greater than or equal to, if it's less than, then remove it
            case ">=": if statisticValue < Float(ruleElements[3])! {
                indexArray.append(index)
            }
                
                // If the user wants less than or equal to, if it's greater than, then remove it
            case "<=": if statisticValue > Float(ruleElements[3])! {
                indexArray.append(index)
            }
                
                // This one is more complex, so it'll be explained about 7 lines later
            case "~":
                valueArray.append((statisticValue,index))
            default: break
            }
        }
        
        // If they use a closest to check, then sort all the values in descending order
        if ruleElements[2] == "~" && !usePlayers.isEmpty {
            
            valueArray.sort {$0.0 > $1.0}
            
            // Keep track of the crucial values
            var smallestDifference: Float = 0
            var smallestDifferenceIndex: Int = 0
            
            // Run through all of the values stored for the players
            for (index,value) in valueArray.enumerated() {
                
                // If the absolute difference between selected value and their value is bigger than the latest one then break
                if abs(value.0 - Float(ruleElements[3])!) > smallestDifference && smallestDifference != 0 {
                    // This is because if the abs value increases, then clearly the values are getting further away from the actual value, and so we should break here
                    break
                    
                    // If the absolute value is smaller than the last smallest value, set the new values accordingly
                } else {
                    smallestDifference = abs(value.0 - Float(ruleElements[3])!)
                    smallestDifferenceIndex = index
                }
            }
            
            // Get the index
            let closestPlayerIndex: Int = valueArray[smallestDifferenceIndex].1
            
            // The only player to keep is the one player who is closest
            usePlayers = [usePlayers[closestPlayerIndex]]
            
            // If it wasn't a closest to, then run the removal process
        } else {
            // Run through each of the players to remove
            for (offsetIndex,index) in indexArray.enumerated() {
                
                // Remove it at index - offset, since if I remove 1 person, the other indexes will shift by 1
                usePlayers.remove(at: index - offsetIndex)
            }
        }
    }
    
    // Run through each of the sorting rules
    for rule in sortRules {
        // Get the rule elements
        var ruleElements: [String] = rule.components(separatedBy: " ")
        
        // Get the statistic to sort on
        let statisticIndex: Int = activity.overallStatistics.searchNamesFor(input: ruleElements[1])
        
        // If it's to be sorted in descending order sort in descending order
        if ruleElements[2] == ">" {
            usePlayers.sort {$0.currentStatistics.statistics[statisticIndex].value > $1.currentStatistics.statistics[statisticIndex].value}
            
            // If it's to be sorted in ascending order sort in ascending order
        } else {
            usePlayers.sort {$0.currentStatistics.statistics[statisticIndex].value < $1.currentStatistics.statistics[statisticIndex].value}
        }
    }
}
