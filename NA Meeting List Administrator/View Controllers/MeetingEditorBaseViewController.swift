//
//  MeetingEditorBaseViewController.swift
//  NA Meeting List Administrator
//
//  Created by MAGSHARE.
//
//  Copyright 2017 MAGSHARE
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  NA Meeting List Administrator is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code.  If not, see <http://www.gnu.org/licenses/>.

import UIKit
import BMLTiOSLib

/* ###################################################################################################################################### */
// MARK: - Base Single Meeting Editor View Controller Class -
/* ###################################################################################################################################### */
/**
 This class describes the basic functionality for a full meeting editor.
 */
class MeetingEditorBaseViewController : EditorViewControllerBaseClass, UITableViewDataSource, UITableViewDelegate {
    /** This is a list of the indexes for our prototypes. */
    enum PrototypeSectionIndexes: Int {
        /** The Meeting Name Editable Section */
        case MeetingNameSection = 0
    }
    
    private var _internalRowHeights: [String:CGFloat] = ["editor-row-0":60]
    
    /** We use this as a common prefix for our reuse IDs, and the index as the suffix. */
    let reuseIDBase = "editor-row-"
    
    /** This is the meeting object for this instance. */
    var meetingObject: BMLTiOSLibEditableMeetingNode! = nil
    
    /** This is a list of all the cells (editor sections). */
    var editorSections: [MeetingEditorViewCell] = []
    
    /** This is the structural table view */
    @IBOutlet var tableView: UITableView!
    
    /** THis is the bar button item for saving changes. */
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /** The following are sections in our table. Each is described by a prototype. */
    
    /** These are the three "dynamics" in the editor. */
    /** If true, then we allow the meeting to be deleted. */
    @IBInspectable var showDelete: Bool!
    /** If true, then we allow the meeting to be saved as a duplicate. */
    @IBInspectable var showDuplicate: Bool!
    /** If true, then we allow meeting history to be show. */
    @IBInspectable var showHistory: Bool!
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     Called as the view is about to appear.
     
     - parameter animated: True, if the appearance is animated.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.editorSections = []
        self.tableView.reloadData()
        self.saveButton.title = NSLocalizedString(self.saveButton.title!, comment: "")
    }
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Called when the NavBar Save button is touched.
     
     - parameter sender: The IB item that called this.
     */
    @IBAction func saveButtonTouched(_ sender: UIBarButtonItem) {
    }
    
    /* ################################################################## */
    // MARK: Instance Methods
    /* ################################################################## */
    /**
     Called when something changes in the various controls.
     
     - parameter inChangedCell: The table cell object that experienced the change.
     */
    func updateEditorDisplay(_ inChangedCell: MeetingNameEditorTableViewCell) {
        
    }
    
    /* ################################################################## */
    // MARK: UITableViewDataSource Methods
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter numberOfRowsInSection: The section index (0-based).
     
     - returns the number of rows to display.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Got this tip from here: http://natecook.com/blog/2014/10/loopy-random-enum-ideas/
        var max: Int = 0
        
        while let _ = PrototypeSectionIndexes(rawValue: max) { max += 1 }
        
        return max
    }
    
    /* ################################################################## */
    /**
     This is the routine that creates a new table row for the Meeting indicated by the index.
     
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns a nice, shiny cell (or sets the state of a reused one).
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseID = self.reuseIDBase + String(indexPath.row)
        
        if let returnableCell = tableView.dequeueReusableCell(withIdentifier: reuseID) as? MeetingEditorViewCell {
            returnableCell.owner = self
            returnableCell.meetingObject = self.meetingObject
            self.editorSections.append(returnableCell)
            return returnableCell
        }
        
        return UITableViewCell()
    }
    
    /* ################################################################## */
    // MARK: UITableViewDelegate Methods
    /* ################################################################## */
    /**
     - parameter tableView: The UITableView object requesting the view
     - parameter cellForRowAt: The IndexPath of the requested cell.
     
     - returns the height of the cell.
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let reuseID = self.reuseIDBase + String(indexPath.row)
        
        switch(reuseID) {   // This allows us to set dynamic heights.
        default:
            if let height = self._internalRowHeights[reuseID] { // By default, we use our table, but we may not have something there.
                return height
            }
        }
        
        return tableView.rowHeight  // All else fails, use the default table row height.
    }
}

/* ###################################################################################################################################### */
// MARK: - Meeting Name Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the base table view class for the various cell prototypes.
 */
class MeetingEditorViewCell: UITableViewCell {
    /** This will contain the meeting object associated with this object. */
    private var _meetingObject: BMLTiOSLibEditableMeetingNode! = nil
    
    /** This is our "owner" meeting editor View Controller */
    var owner: MeetingEditorBaseViewController! = nil
    
    /* ################################################################## */
    /**
     This is an accessor for the meeting object. Getting is no big deal, but setting calls our meetingObjectUpdated() method.
     */
    var meetingObject: BMLTiOSLibEditableMeetingNode! {
        get { return self._meetingObject }
        set {
            self._meetingObject = newValue
            self.meetingObjectUpdated()
        }
    }
    
    /* ################################################################## */
    /**
     This is designed to be overloaded. This is called when the meetingObject property is set, and gives us a chance to set up our object.
     */
    func meetingObjectUpdated(){}
}

/* ###################################################################################################################################### */
// MARK: - Meeting Name Editor Table Cell Class -
/* ###################################################################################################################################### */
/**
 This is the table view class for the name editor prototype.
 */
class MeetingNameEditorTableViewCell: MeetingEditorViewCell {
    /** This is the meeting name section. */
    @IBOutlet weak var meetingNameLabel: UILabel!
    @IBOutlet weak var meetingNameTextField: UITextField!
    
    /* ################################################################## */
    // MARK: IB Methods
    /* ################################################################## */
    /**
     Respond to text changing in the text field.
     
     - parameter sender: The IB object that initiated this change.
     */
    @IBAction func meetingNameTextChanged(_ sender: UITextField) {
        self.meetingObject.name = sender.text!
        self.owner.updateEditorDisplay(self)
    }
    
    /* ################################################################## */
    // MARK: Overridden Base Class Methods
    /* ################################################################## */
    /**
     We set up our label, name and placeholder.
     */
    override func meetingObjectUpdated() {
        self.meetingNameLabel.text = NSLocalizedString(self.meetingNameLabel.text!, comment: "")
        self.meetingNameTextField.placeholder = NSLocalizedString(self.meetingNameTextField.placeholder!, comment: "")
        self.meetingNameTextField.text = self.meetingObject.name
    }
}
