import Foundation

// Initial declaration of the user, who is the store of every permanent value within the code and is being saved/loaded
var user: User = User(activities: [], details: UserDetails(username: "", password: ""), playerCount: 0, groupCount: 0, teamCount: 0)

// Struct for the user
//      Could be a class, but I prefer struct
struct User: Codable {
    // Stores all of the users activities
    var activities: [Activity]
    
    // Stores their account details
    var details: UserDetails
    
    // Stores their counts for later use in creation with unique ID's
    //          Could be their own struct that stores it, but it's fine as just values here
    var playerCount: Int
    var groupCount: Int
    var teamCount: Int
}

// Stores the users account details
struct UserDetails: Codable {
    var username: String
    var password: String
}

// Stores an activity and it's associated values
//      Stores it using class since it's never being referenced while not needing to be changed in value
class Activity: Codable {
    
    // Stores the activities name
    var name: String
    
    // Stores whether it has teams, groups, etc.
    var storageType: Int
    
    // Stores the overall players for the activity
    var people: [Person]
    
    // Stores the groups for the activity
    var groups: [Group]
    
    // Stores the overall teams for the activity
    var teams: [Team]
    
    // Stores any search rules that the player has created for this activity
    var searchRules: [SearchRule]
    
    // Stores the total combined statistics across every player in the group so that you can view this stuff
    //          Like maybe you want to know when your group reaches a total of 10000 kills, or when the average kdr across the whole activity is above 1
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
    
    // Function to get a teams postion within the activities teams
    func searchTeamsFor(ID: Int) -> Int {
        // Run through all the teams
        for (index,team) in teams.enumerated() {
            
            // If the ID matches then return their index
            if team.uniqueID == ID {
                return index
            }
        }
        return -1
    }
    
    // Function to get a groups postion within the activities teams
    func searchGroupsFor(ID: Int) -> Int {
        // Run through all the groups
        for (index,group) in groups.enumerated() {
            
            // If the ID matches then return their index
            if group.uniqueID == ID {
                return index
            }
        }
        return -1
    }
    
    // Function to completely remove a team from an activity
    func removeGroup(_ group: Group) {
        
        // Remove them from the activity
        let groupCheck: Int = searchGroupsFor(ID: group.uniqueID)
        if groupCheck != -1 {
            groups.remove(at: groupCheck)
        }
    }
    
    // Function to completely remove a team from an activity
    func removeTeam(_ team: Team) {
        // Remove them from the groups
        for group in groups {
            let teamCheck: Int = group.searchTeamsFor(ID: team.uniqueID)
            if teamCheck != -1 {
                group.teams.remove(at: teamCheck)
            }
        }
        
        // Remove them from the activity
        let teamCheck: Int = searchTeamsFor(ID: team.uniqueID)
        if teamCheck != -1 {
            teams.remove(at: teamCheck)
        }
    }
    
    // Function to completely remove a player from an activity
    func removePerson(_ player: Person) {
        // Remove them from the teams
        for team in teams {
            let playerCheck: Int = team.searchPlayersFor(ID: player.details.uniqueID)
            if playerCheck != -1 {
                team.people.remove(at: playerCheck)
            }
        }
        
        // Remove them from the groups
        for group in groups {
            let playerCheck: Int = group.searchPlayersFor(ID: player.details.uniqueID)
            if playerCheck != -1 {
                group.people.remove(at: playerCheck)
            }
        }
        
        // Remove them from the activity
        let playerCheck: Int = searchPlayersFor(ID: player.details.uniqueID)
        if playerCheck != -1 {
            people.remove(at: playerCheck)
        }
    }
    

    // Function to calculate the current total statistics of an activity
    func calculateCurrentStatistics() {
        // First reset the values to 0 so that all base values are removed
        for (index,_) in self.combined.statistics.enumerated() {
            self.combined.statistics[index].value = 0
        }
        
        // Run through each of the people in the activity
        for player in self.people {
            player.calculateCurrentStatistics()
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
        combined.statistics.append(newStatistic)
        
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
    
    // Init because classes require it
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

// Struct to store a search rule
struct SearchRule: Codable {
    // Stores the name the user used for it
    var name: String
    
    // Stores the rules used in the search
    var rules: [String]
    
    // Stores the players who are from that search
    var players: [Person]
}

// Used to hold groups of people within an activity
// Can hold further teams within the group
class Group: PlayerHolder {
    var teams: [Team] // The teams within the group
    
    init(name: String, people: [Person], teams: [Team], uniqueID: Int) {
        self.teams = teams
        
        super.init(name: name, people: people, uniqueID: uniqueID)
    }
    
    enum CodingKeys: String, CodingKey {
        case teams
    }

    required init(from decoder: Decoder) throws {
        // Decode Group-specific values first
        let container = try decoder.container(keyedBy: CodingKeys.self)
        teams = try container.decode([Team].self, forKey: .teams)
        
        // Then decode the superclass
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teams, forKey: .teams)
        
        // Then encode superclass
        try super.encode(to: encoder)
    }
    
    // Function to get a players postion within the groups's players
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
    
    // Function to get a teams postion within the groups's teams
    func searchTeamsFor(ID: Int) -> Int {
        // Run through all the teams
        for (index,team) in teams.enumerated() {
            
            // If the ID matches then return their index
            if team.uniqueID == ID {
                return index
            }
        }
        return -1
    }
}

// Used to hold teams of people within an activity
// Cannot hold further groups within the team
class Team: PlayerHolder {
    
    override init(name: String, people: [Person], uniqueID: Int) {
        super.init(name: name, people: people, uniqueID: uniqueID)
    }
    
    required init(from decoder: Decoder) throws {
        // Then decode the superclass
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        // Then encode superclass
        try super.encode(to: encoder)
    }
    
    // Function to get a players postion within the teams's players
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
        for (index,_) in self.currentStatistics.statistics.enumerated() {
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

// Used to uphold inheritance/generalisation or whichever one it is
class PlayerHolder: Codable {
    var name: String // Name of the group/team
    var people: [Person] // The people in the group/team
    var uniqueID: Int // The unqiue identifier of the group/team
    
    init(name: String, people: [Person], uniqueID: Int) {
        self.name = name
        self.people = people
        self.uniqueID = uniqueID
    }
    
    enum CodingKeys: String, CodingKey {
        case name, people, uniqueID
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        people = try container.decode([Person].self, forKey: .people)
        uniqueID = try container.decode(Int.self, forKey: .uniqueID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(people, forKey: .people)
        try container.encode(uniqueID, forKey: .uniqueID)
    }
}

struct PersonDetails: Codable {
    var name: String
    var uniqueID: Int
    var group: FixedStorage
    var team: FixedStorage
    
    // Function to set the players group and team details by inputting either a group or team
    
    // Mr Robertson, this is some good use of inheriting and generalising cause I'm using the array of PlayerHolders to mean both Groups and Teams!!!!!!!!!!
    mutating func getFrom(_ input: [PlayerHolder]) {
        
        // If the input is an array then run this code for each of the values
        if input.count != 1 {
            for value in input {
                self.getFrom([value])
            }
            
        // If the input is a group, set the players group id and index
        } else if input[0] is Group {
            let addGroup = input[0] as! Group
            group.id = addGroup.uniqueID
            group.index = contentManager.selectedValues.group
        
        // If the input is a team, set the players team id and index
        } else if input[0] is Team {
            let addTeam = input[0] as! Team
            team.id = addTeam.uniqueID
            team.index = contentManager.selectedValues.team
        }
    }
}

// Structure to store a title of an event/period and then the associated stats
struct StatisticHolder: Codable {
    // Description/name of the event/period as a string
    var description: String
    
    // Statistics as an array since we can have multiple
    var statistics: [Statistic]
}

// Structure that holds a value and a name, and potentially a rule
//      Struct not class since we reuse the statistic for multiple people, and if it was a class, they'd all be sharing the same value and not just copying the statistic.
struct Statistic: Codable {
    // Statistic name as a string
    var name: String
    
    // Value as a float since potential division or use of decimal numbers
    var value: Float
    
    // Calculation as array, since some people can have no calculations
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

// A class used to store automatic calculations for variables
class Calculation: Codable {
    // Stores the first term as a string since it might be a value or a statistic
    var primaryTerm: String
    
    // Stores the Opertion as an Opertion value, since it's either addition, multiplication, division or subtraction
    var operation: Operation
    
    // Stores the second term as a string since it might be a value or a statistic
    var secondaryTerm: String
    
    init(primaryTerm: String, operation: Operation, secondaryTerm: String) {
        self.primaryTerm = primaryTerm
        self.operation = operation
        self.secondaryTerm = secondaryTerm
    }
    
    // Function that easily summarises a calculation into text
    func toString() -> String {
        return "\(primaryTerm) \(operation.toString()) \(secondaryTerm)"
    }
    
    // Function to run a calculation for a given person
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

// Easy use of values for automatic calculations
enum Operation: Codable {
    // Make them the 4 basic operators
    //         No complex stuff like power of or logarithm or anything complex like that since simplicity
    case add, subtract, multiply, divide
    
    // Function that turns an operation into it's most basic and well known text representation
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

// Function to allow lowercasing only the title values in my contentManager.tableValues
extension [(String, String)] {
    // Set all of the .0 values to lowercase
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
        let ruleElements: [String] = rule.components(separatedBy: " ")
        
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
        let ruleElements: [String] = rule.components(separatedBy: " ")
        
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

// Function to make getting an activity easier
func getSelectedActivity() -> Activity {
    // Just get and return the activity
    let activity: Activity = user.activities[contentManager.selectedValues.activity]
    return activity
}

// Function to make getting a group easier
func getSelectedGroup() -> Group {
    
    // Get the group from the activity
    let activity: Activity = getSelectedActivity()
    let group: Group = activity.groups[contentManager.selectedValues.group]
    return group
}

// Function to make getting a team easier
func getSelectedTeam() -> Team {
    // Get the activity
    let activity: Activity = getSelectedActivity()
    
    // If we have group selected then get team from group
    if contentManager.selectedValues.group != -1 {
        let group: Group = getSelectedGroup()
        let team: Team = group.teams[contentManager.selectedValues.team]
        return team
    
    // If we have no group selected then get team from activity
    } else {
        let team: Team = activity.teams[contentManager.selectedValues.team]
        return team
    }
}

func getSelectedTeams() -> [Team] {
    let activity: Activity = getSelectedActivity()
    if contentManager.selectedValues.group == -1 {
        let teams: [Team] = activity.teams
        return teams
    } else {
        let group: Group = getSelectedGroup()
        let teams: [Team] = group.teams
        return teams
    }
}

// Function to make getting a player easier
func getSelectedPlayer() -> Person {
    // Get the activity
    let activity: Activity = getSelectedActivity()
    
    // If no group or team is selected then get from activity
    if contentManager.selectedValues.team == -1 && contentManager.selectedValues.group == -1 {
        let player: Person = activity.people[contentManager.selectedValues.player]
        return player
    
    // If there is a group selected and no team selected
    } else if contentManager.selectedValues.team == -1 {
        let group: Group = getSelectedGroup()
        let player: Person = group.people[contentManager.selectedValues.player]
        return player
    
    // And finally if none of those worked then it's A-G-T-P or A-T-P, which means we're relying on a team to get the player, so all complex logic is already handled in the getSelectedTeam() function
    } else {
        let team: Team = getSelectedTeam()
        let player: Person = team.people[contentManager.selectedValues.player]
        return player
    }
}

func getSelectedPlayers() -> [Person] {
    // Get the activity
    let activity: Activity = getSelectedActivity()
    
    // First check if it's a search rule
    if contentManager.selectedValues.search != -1 {
        let players: [Person] = getSelectedSearch().players
        return players
        
    // If no group or team is selected then get from activity
    } else if contentManager.selectedValues.team == -1 && contentManager.selectedValues.group == -1 {
        let players: [Person] = activity.people
        return players
    
    // If there is a group selected and no team selected
    } else if contentManager.selectedValues.team == -1 && contentManager.selectedValues.group != -1 {
        let group: Group = getSelectedGroup()
        let players: [Person] = group.people
        return players
    
    // And finally if none of those worked then it's A-G-T-P or A-T-P, which means we're relying on a team to get the player, so all complex logic is already handled in the getSelectedTeam() function
    } else if contentManager.selectedValues.team != -1 && contentManager.selectedValues.group != -1 {
        let team: Team = getSelectedTeam()
        let players: [Person] = team.people
        return players
    }
    
    // Otherwise let's just return a blank case (Which shouldn't ever happen)
    return []
}

// Function to get a search rule from the saved value
func getSelectedSearch() -> SearchRule {
    let activity: Activity = getSelectedActivity()
    let searchRule: SearchRule = activity.searchRules[contentManager.selectedValues.search]
    return searchRule
}

// Function to get a player from a saved array of ID's
func getPlayerFromSavedNumber() -> Person {
    let activity: Activity = getSelectedActivity()
    let playerID: Int = contentManager.savedIntegers[contentManager.savedIntegers[0]]
    let playerIndex: Int = activity.searchPlayersFor(ID: playerID)
    return activity.people[playerIndex]
}
