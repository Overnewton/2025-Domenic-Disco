// The functions here are for getting values easily without needing to use too complex code inside my actual code

// For example, I can just type "getSelectedPlayer()" instead of typing:

//  user.activities[contentManager.selectedValues.activity]
//      .groups[contentManager.selectedValues.group]
//          .teams[contentManager.selectedValues.team]
//              .people[contentManager.selectedValues.player]

import Foundation



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

// Function to make getting an array of groups easier
func getSelectedGroups() -> [Group] {
    // Get the groups from the activity
    let activity: Activity = getSelectedActivity()
    let groups: [Group] = activity.groups
    return groups
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

// Function to make getting an array of teams easier
func getSelectedTeams() -> [Team] {
    let activity: Activity = getSelectedActivity()
    
    // If we have group selected then get teams from group
    if contentManager.selectedValues.group != -1 {
        let teams: [Team] = activity.teams
        return teams
    
    // If we have no group selected then get teams from activity
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

// Function to make getting an array of players easier
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
