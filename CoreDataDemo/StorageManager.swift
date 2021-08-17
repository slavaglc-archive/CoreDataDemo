

import CoreData

public class StorageManager {
    
   public static let shared = StorageManager()
   let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
 
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    private let context: NSManagedObjectContext!
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            return taskList
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    func fetchTasks(completion: ([Task]) ->()) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        let context = persistentContainer.viewContext
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(taskList)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String, completion: @escaping (Task)->()) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else {
            return
        }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return }
        task.name = taskName
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
            completion(task)
        }
    }
    
    func deleteTask(task: Task, completion: ()->()) {
        context.delete(task)
      //  saveContext()
        do {
           try context.save()
            completion()
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
}
