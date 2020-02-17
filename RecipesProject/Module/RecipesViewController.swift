//
//  ViewController.swift
//  RecipesProject
//
//  Created by Tech Labs on 17/06/1441 AH.
//  Copyright © 1441 Tech Labs. All rights reserved.
//

import UIKit

class RecipesViewController: UITableViewController {
    
        private let contactCellIdentifier = "Cell"
        private var filteredUsers = [UserModel]()
        //private var allUsers = [UserModel]()
        private var searchController = UISearchController(searchResultsController: nil)
        //let currentUser = Auth.auth().currentUser
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.register(ContactCell.self, forCellReuseIdentifier: contactCellIdentifier)
            searchController.searchResultsUpdater = self
            searchController.createSearchController(self)
            navigationItem.title = "People"
        }
          
          // MARK: - Table view data source

          override func numberOfSections(in tableView: UITableView) -> Int {
              // #warning Incomplete implementation, return the number of sections

            return 1
            
        }
          override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
              // #warning Incomplete implementation, return the number of rows
                  return filteredUsers.count
          }
          override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
              let cell = tableView.dequeueReusableCell(withIdentifier: contactCellIdentifier , for: indexPath) as! ContactCell
            cell.additionDelegate = self
            let name = filteredUsers[indexPath.row].userName!
            cell.nameLabel.text = name
            cell.belowDetailedLabel.text = "ios developer"
            cell.profileImageView.image = UIImage(named: "female.png")
            return cell
          }
        override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 70
            
        }
        // MARK: - Helpers
        private func filterContentForSearchText(users: [UserModel],searchText: String) {
          filteredUsers = users.filter({
                (user: UserModel) -> Bool in
                let userName = user.userName?.lowercased()
                let index = searchText.count <= userName!.count ? userName!.index(userName!.startIndex, offsetBy: searchText.count) : String.Index(encodedOffset: 0)
                let mySubString = userName!.prefix(upTo: index)
                return String(mySubString).contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
        private func addNewContact(Friends_id: [String], firstName: String, secondName: String) {
            FirebaseHelper_Chat.addChatRoom(Friends_id: Friends_id,firstName: firstName,secondName: secondName,completion:{ response in
                switch response {
                case true:
                    print("chatRoom is created successfully")
                case false:
                    break
                }
            })
        }
        private func appendNewFriend(contactCell: IndexPath) {
            let contact = filteredUsers[contactCell.row]
            var currentUser = AppSettings.getCurrentUserFromUserDefaults()
            currentUser.friends?.append(contact.userId!)
                FirebaseHelper_User.addUserToDatabase(user: currentUser, didSucced: {
                            (success) in
                             if success {
                            self.filteredUsers.remove(at: contactCell.row)
                            self.tableView.reloadData()
                            AppSettings.removeUserFromUserDefaults()
                            AppSettings.addUserToUserDefaults(user: currentUser)
                        }
                    })
        }
        private func getAllUsers(text: String) {
            allUsers.removeAll()
            let currentUser = AppSettings.getCurrentUserFromUserDefaults()
                do {
                       try FirebaseHelper_User.getUsers(onLoadUsers: {
                                    users in
                        if let usersList = users {
                            for (index,user) in usersList.enumerated() {
                                if (currentUser.friends?.contains(user.userId!))! || user == AppSettings.getCurrentUserFromUserDefaults() {
                                print(usersList[index])
                           }
                              else {
                                self.allUsers.append(user)
                                self.tableView.reloadData()
                               }
                          }
                                    if !self.allUsers.isEmpty {
                                        self.filterContentForSearchText(users: self.allUsers, searchText: text)
                                         }
                                    }
                                    })
                                }
                                catch {
                                    print(error.localizedDescription)
                                }

        }
    }
    extension PeopleViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            getAllUsers(text: searchController.searchBar.text ?? " ")
        }
    }
    extension PeopleViewController: ContactAddtionDelegate {
        func didContactAdd(cell: UITableViewCell) {
            let contactCell = tableView.indexPath(for: cell)
            appendNewFriend(contactCell: contactCell!)
        }
    }
