// The functions here are for help in testing for easy generation of players so that I can super easily test my new code

import Foundation



// Generated a more controlled test,
// where you have a fixed number of statstics (5)
// Groups (2)
// Teams in Groups (2 teams per group)
// Teams not in Groups (2 teams outside of groups)
// Players in Groups (10 per group)
// Players in Teams in Groups (10 per team)
// Players in Teams not in Groups (10 per team)
// Players in Activity (10)
// And a more acceptable range of statistics, being between 0.9 and 1.1x the average which is also fixed from 1000-5000 so min and max statistic values of 900 and 5500
func controlledTest() {
    user.activities.append(Activity(name: "Test Activity", storageType: 1, people: [], groups: [], teams: [], combined: StatisticHolder(description: "Overall", statistics: []), overallStatistics: [], searchRules: []))
    
    for index in 1...5 {
        let newStatistic: Statistic = Statistic(name: "Statistic\(index)", value: Float(index * 1000), rule: [])
        user.activities[user.activities.count - 1].overallStatistics.append(newStatistic)
        user.activities[user.activities.count - 1].combined.statistics.append(newStatistic)
    }
    
    for index in 1...10 {
        let newPlayer: Person = controlledPlayer(for: user.activities.last!)
        user.activities.last!.people.append(newPlayer)
    }
    
    for index in 1...2 {
        let newGroup: Group = Group(name: "Group \(index)", people: [], teams: [], uniqueID: index)
        user.activities.last!.groups.append(newGroup)
        
        for index in 1...10 {
            let newPlayer: Person = controlledPlayer(for: user.activities.last!)
            user.activities.last!.groups.last!.people.append(newPlayer)
            user.activities.last!.people.append(newPlayer)
        }
        
        for index2 in 1...2 {
            let newTeam: Team = Team(name: "Group \(index), Team \(index2)", people: [], uniqueID: (index2 + (2 * (1-index))))
            user.activities.last!.teams.append(newTeam)
            newGroup.teams.append(newTeam)
            
            for index in 1...10 {
                let newPlayer: Person = controlledPlayer(for: user.activities.last!)
                user.activities.last!.groups.last!.teams.last!.people.append(newPlayer)
                user.activities.last!.groups.last!.people.append(newPlayer)
                user.activities.last!.people.append(newPlayer)
            }
        }
    }
    
    for index in 1...2 {
        let newTeam: Team = Team(name: "Activity Team \(index)", people: [], uniqueID: (index + 4))
        user.activities.last!.teams.append(newTeam)
        
        for index in 1...10 {
            let newPlayer: Person = controlledPlayer(for: user.activities.last!)
            user.activities.last!.teams.last!.people.append(newPlayer)
            user.activities.last!.people.append(newPlayer)
        }
    }
}

// Generated a more controlled player to add for a test
func controlledPlayer(for activity: Activity) -> Person {
    let returnPerson: Person = Person(details: PersonDetails(name: "Player \(activity.people.count)", uniqueID: user.playerCount, group: FixedStorage(index: -1, name: "", id: -1), team: FixedStorage(index: -1, name: "", id: -1)), currentStatistics: StatisticHolder(description: "Current", statistics: []), pastPeriods: [:])
    user.playerCount += 1
    
    returnPerson.currentStatistics.statistics = activity.overallStatistics
    
    for index in 1...2 {
        returnPerson.pastPeriods[index] = StatisticHolder(description: "Period \(index)", statistics: activity.overallStatistics)
        for (index2,statistic) in returnPerson.pastPeriods[index]!.statistics.enumerated() {
            if statistic.rule.isEmpty {
                returnPerson.pastPeriods[index]?.statistics[index2].value *= Float.random(in: 0.9...1.1)
            }
        }
    }
    
    returnPerson.calculateCurrentStatistics()
    
    return returnPerson
}

// Function used for testing that adds 4 random activities to your user and fills the activities with players and statistics
func addTestActivities() {
    for index in 1...4 {
        user.activities.append(Activity(name: "Activity \(index)", storageType: 1, people: [], groups: [], teams: [], combined: StatisticHolder(description: "Overall", statistics: []), overallStatistics: [], searchRules: []))
        for index in 1...Int.random(in: 5...12) {
            let newStatistic: Statistic = Statistic(name: "Statistic\(index)", value: Float.random(in: 0...5000), rule: [])
            user.activities[user.activities.count - 1].overallStatistics.append(newStatistic)
            user.activities[user.activities.count - 1].combined.statistics.append(newStatistic)
        }
        for _ in 1...Int.random(in: 100...300) {
            user.activities.last!.people.append(createTestPlayer(for: user.activities.last!))
        }
    }
}

// Function that creates a random player for a given activity just for use in testing that the application works
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
