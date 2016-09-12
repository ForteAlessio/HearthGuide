/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import CoreData

@objc(ManagedNode)
internal class ManagedNode: ManagedObject {
    @NSManaged internal var nodeClass: NSNumber
    @NSManaged internal var type: String
    @NSManaged internal var createdDate: Date
    @NSManaged internal var propertySet: NSSet
    @NSManaged internal var tagSet: NSSet
    @NSManaged internal var groupSet: NSSet
    
    /// A reference to the Nodes unique ID.
    internal var id: String {
        guard let moc = managedObjectContext else {
            fatalError("[Graph Error: Cannot obtain permanent objectID]")
        }
        
        var result: String?
        moc.performAndWait { [unowned self, unowned moc] in
            do {
                try moc.obtainPermanentIDs(for: [self])
            } catch let e as NSError {
                fatalError("[Graph Error: Cannot obtain permanent objectID - \(e.localizedDescription)]")
            }
            result = String(stringInterpolationSegment: self.nodeClass) + self.type + self.objectID.uriRepresentation().lastPathComponent
        }
        return result!
    }
    
    /// A reference to the tags.
    internal var tags: Set<String> {
        var t = Set<String>()
        guard let moc = managedObjectContext else {
            return t
        }
        moc.performAndWait { [unowned self] in
            self.tagSet.forEach { (object: Any) in
                if let tag = object as? ManagedTag {
                    t.insert(tag.name)
                }
            }
        }
        return t
    }
    
    /// A reference to the groups.
    internal var groups: Set<String> {
        var g = Set<String>()
        guard let moc = managedObjectContext else {
            return g
        }
        moc.performAndWait { [unowned self] in
            self.groupSet.forEach { (object: Any) in
                if let group = object as? ManagedGroup {
                    g.insert(group.name)
                }
            }
        }
        return g
    }
    
    /// A reference to the properties.
    internal var properties: [String: Any] {
        var p = [String: Any]()
        guard let moc = managedObjectContext else {
            return p
        }
        moc.performAndWait { [unowned self] in
            self.propertySet.forEach { (object: Any) in
                if let property = object as? ManagedProperty {
                    p[property.name] = property.object
                }
            }
        }
        return p
    }
    
    /**
     Initializer that accepts an identifier, a type, and a NSManagedObjectContext.
     - Parameter identifier: A model identifier.
     - Parameter type: A reference to the Entity type.
     - Parameter managedObjectContext: A reference to the NSManagedObejctContext.
     */
    internal convenience init(identifier: String, type: String, managedObjectContext: NSManagedObjectContext) {
        self.init(entity: NSEntityDescription.entity(forEntityName: identifier, in: managedObjectContext)!, insertInto: managedObjectContext)
        self.type = type
        createdDate = Date()
        propertySet = NSSet()
        tagSet = NSSet()
        groupSet = NSSet()
    }
    
    /**
     Access properties using the subscript operator.
     - Parameter name: A property name value.
     - Returns: The optional Any value.
     */
    internal subscript(name: String) -> Any? {
        get {
            var value: Any?
            guard let moc = managedObjectContext else {
                return value
            }
            moc.performAndWait { [unowned self] in
                for property in self.propertySet {
                    guard let p = property as? ManagedProperty else {
                        return
                    }
                    if name == p.name {
                        value = p.object
                        break
                    }
                }
            }
            return value
        }
    }
    
    /**
     Checks if the ManagedNode has a given tag.
     - Parameter tag: A tag name.
     - Returns: A boolean of the result, true if a member, false
     otherwise.
     */
    internal func has(tag name: String) -> Bool {
        guard let moc = managedObjectContext else {
            return false
        }
        var result: Bool? = false
        moc.performAndWait { [unowned self] in
            for tag in self.tagSet {
                if name == (tag as? ManagedTag)?.name {
                    result = true
                    break
                }
            }
        }
        return result!
    }
    
    /**
     Checks if the ManagedNode is a member of a group.
     - Parameter of group: A group name.
     - Returns: A boolean of the result, true if a member, false
     otherwise.
     */
    internal func member(of group: String) -> Bool {
        guard let moc = managedObjectContext else {
            return false
        }
        var result: Bool? = false
        moc.performAndWait { [unowned self] in
            for g in self.groupSet {
                if group == (g as? ManagedGroup)?.name {
                    result = true
                    break
                }
            }
        }
        return result!
    }
}

internal func <=(lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    return lhs.id <= rhs.id
}

internal func >=(lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    return lhs.id >= rhs.id
}

internal func >(lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    return lhs.id > rhs.id
}

internal func <(lhs: ManagedNode, rhs: ManagedNode) -> Bool {
    return lhs.id < rhs.id
}

