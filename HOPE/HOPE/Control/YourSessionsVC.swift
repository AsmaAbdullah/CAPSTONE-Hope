//
//  YourSessionsVC.swift
//  HOPE
//
//  Created by Asma on 14/12/2021.
//

import UIKit
import CoreData
import FirebaseAuth


class YourSessionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var listSession = [SessionDetile]()
    var selectedListSession: SetDetile?
    var yourSessionsList: [YourSessionsList] = []
    
    
    // MARK: - CORE-DATA
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BeneficiarySessions")
        
        container.loadPersistentStores (completionHandler: { desc, error in
            if let readError = error {
                print(readError)
            }
        })
        return container
    }()
    
    //MARK: Outlet for table view..
    
    @IBOutlet weak var yourSessionTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yourSessionTable.delegate = self
        yourSessionTable.dataSource = self
        
        setListSession()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchAllLists()
        self.yourSessionTable.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yourSessionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "yourSessionCell", for: indexPath)
        cell.textLabel?.text = yourSessionsList[indexPath.row].titleSession?.localaized
        cell.imageView?.image = UIImage(named: yourSessionsList[indexPath.row].imageSession ?? "")
        
        cell.imageView?.layer.cornerRadius = 12
        cell.imageView?.layer.borderColor = UIColor.lightGray.cgColor
        cell.imageView?.layer.borderWidth = 1.0
        cell.imageView?.frame = CGRect(x: 30.0, y: 30.0, width: 0.0, height: 30.0)
        cell.textLabel?.font = UIFont(name: "Gill Sans", size: 20)
        cell.textLabel?.textColor = UIColor(named: "Font")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let theSession = listSession.first(where: { sessionDetail in
            return sessionDetail.title == yourSessionsList[indexPath.row].titleSession?.localaized
        })
        
        if let data = theSession {
            selectedListSession = SetDetile(setTitle: data.title.localaized, setImageSession: data.imageSession, setDefinition: data.definition.localaized, setFirstSubHead: data.firstSubHead.localaized, setFirstContent: data.firstContent.localaized, setSecondSubhead: data.secondSubhead.localaized, setSecondContent: data.secondContent.localaized, setThirdSubhead: data.thirdSubhead.localaized, setThirdContent: data.thirdContent.localaized)
            
            //        selectedListSession = listSession[indexPath.row]
            performSegue(withIdentifier: "toSession", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? SessionsVC {
            vc.selectedListSession = selectedListSession
        }
    }
    
    //MARK: The function of deleting the session from the account
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let sessions = yourSessionsList[indexPath.row]
            yourSessionsList.remove(at: indexPath.row)
            yourSessionTable.deleteRows(at: [indexPath], with: .automatic)
            
            //MARK: Delete from core data object
            let context = persistentContainer.viewContext
            context.delete(sessions)
            do {
                try context.save()
            } catch let saveErr {
                print("failed to delete", saveErr)
            }
        }
    }
    
    
    //MARK: - Fetch for COREDATA
    
    func fetchAllLists() {
        let context = persistentContainer.viewContext
        let request = YourSessionsList.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", Auth.auth().currentUser?.uid ?? "")
        do {
            yourSessionsList = try context.fetch(request)
        } catch {
            print(error)
        }
    }
    
    
    //MARK: Function for the data displayed in the application
    
    fileprivate func setListSession() {
        listSession.append(SessionDetile.init(title: "Self-Image and Cancer".localaized, imageSession: UIImage(resource: .Session1)!, definition: "Self-image is how a person views himself or herself. Because of the many physical and emotional changes after a cancer diagnosis, people may experience positive and negative changes to their self-image.".localaized, firstSubHead: "Physical changes".localaized, firstContent: "Both cancer and its treatment may change how you look. How you feel about your appearance is called body image. Many people with cancer feel self-conscious about changes to their bodies. Some of the more common physical changes of cancer include:\n- Hair loss\n- Weight gain or weight loss\n- Surgery scars\n- Rash, typically from drug therapies\n- Loss of an organ, limb, or breast\n- The need for an ostomy, which is a surgical opening that allows bodily waste to exit the body into a bag\n- Fatigue or loss of energy, which can cause you to give up activities you once enjoyed.\n  Many of these changes will resolve or get better as time passes after treatment. But make sure to share any concerns you have with your health care team. Ask them for more information about ways to relieve these symptoms or the emotional discomfort you may feel because of them.".localaized, secondSubhead: "Emotional changes", secondContent: "Cancer disrupts so many parts of a person’s life, from relationships to work and hobbies. Depending on the seriousness of the illness and the chance of recovery, it may also force you to make changes to your future and deal with the chance of dying. During this time, you may feel many different emotions:\n- Sadness, Anxiety\n- Loneliness or a sense of being different from others\n- Fear, Anger, Frustration, Guilt\n- Feeling out of control\n- A change in the way you think about yourself and the future.\n But many people with cancer have also reported positive changes. These positive changes can be emotional, spiritual, or intellectual. For example, you may feel:\n- An appreciation for the strength of your body.\n- Peace, Gratitude\n- Awareness and appreciation that life is short and special.\n- Grateful for new important relationships with caregivers and other patients.\n- A shift in priorities.\n- Clarity about meaning in life and personal goals".localaized, thirdSubhead: "Coping with self-image changes".localaized, thirdContent: "You may view yourself and your body differently after cancer. These tips may help you cope:\n- Allow time to adjust. Accepting a cancer diagnosis and undergoing treatment may change your life. It takes time to adapt.\n- Talk with others who have been in similar situations.\n- Build a network of friends and family who can support you and help you feel positive.\n- Ask for and accept help. Pass off tasks that take up your energy and are not pleasing to you.\n- Stay calm and, if you are able, embrace humor.\n- Ask your health care team about possible reconstructive surgery, prosthetic devices, and/or cosmetic solutions.\n- As much as possible, remain active.\n- Seek counseling.".localaized))
        
        listSession.append(SessionDetile.init(title: "Coping With Uncertainty".localaized, imageSession: UIImage(resource: .Session2)!, definition: "Many people with cancer may feel a lack of certainty about what the future holds. After a cancer diagnosis, you may feel that your life is less secure than it once was. It is important to ask for support when you are feeling this way.".localaized, firstSubHead: "Causes of uncertainty".localaized, firstContent: "Both newly diagnosed patients and long-term survivors have common worries. These may include:\n- Having to put plans on hold. You may feel like you are unable to look to the future. Making plans is difficult for many practical reasons. For instance, it can be hard to plan a family vacation when you may not know exactly when you will have treatment. You may not be able to commit to a lunch date because you cannot predict how you will be feeling. Some people feel unable to make any plans. One approach that works well for many people with cancer is to remain flexible and accept that plans may change.\n- Fear about cancer treatment and side effects. You may be worried or scared of the possible side effects of treatment, such as pain, nausea, or fatigue. Or you may fear becoming dependent on others during cancer treatment or missing activities that you enjoy. Learn more about coping with the fear of treatment side effects.\nLong-term cancer survivors may worry about having late effects. These are side effects of cancer treatment that happen months or years after treatment ends. Talk with your health care team about possible late effects and how they can be managed. There are resources available if you need help.\n- The treatment will not work. No treatment works the same for every person, even those with the same type of cancer. Some treatments are more effective for some people. Other treatments may work but cause side effects.".localaized, secondSubhead: "", secondContent: "- The treatment will stop working. Many times, people continue to receive a treatment until it stops working. This is especially true for those with cancer that has spread or those with cancer that is controlled with drugs for a long time. It is scary to think that the drug could stop working, even if you know that there are other treatment options.\n- The cancer will come back. A cancer recurrence is when the cancer returns after treatment. It is a top fear of many cancer survivors. If you worry about this, you may find yourself paying attention to every potential symptom you have. In turn, this can increase your general level of anxiety. Learn more about coping with the fear of recurrence.\n- Fear of dying or losing someone you love. Facing the idea of dying can be difficult. Feeling fear is natural when you think about dying or losing someone you love. It’s normal to struggle with a fear of death. Yet, if these feelings become stronger, talk with your health care team about resources to help you cope.".localaized, thirdSubhead: "Dealing with the “what ifs” of cancer".localaized, thirdContent: "Acknowledging the unknowns of cancer may make you feel anxious, angry, sad, or afraid. You may even have physical symptoms from these feelings. For instance, it may cause sleeping problems or make it harder to focus at work. Learning to manage the uncertainty is an important part of staying healthy. These tips may help you cope:\n- Recognize that there are situations you can control and those you cannot. As hard as it sounds, many people find it helpful to let go of those things that they cannot change and focus on their reaction to events.\n- Talk with your health care team if your feelings of uncertainty are affecting your daily life. They can help you find the resources you need to feel better.".localaized))
        
        listSession.append(SessionDetile.init(title: "Managing Stress".localaized, imageSession: UIImage(resource: .Session3)!, definition: "A disease such as cancer is often one of the most stressful experiences of a person's life. Coping with cancer can be more challenging with added stress from work, family, or financial concerns.".localaized, firstSubHead: "Tips for reducing stress".localaized, firstContent: "Stressors are sources of stress. Some stressors are predictable and, therefore, sometimes avoidable. Consider the following tips for reducing stress:\n- Avoid scheduling conflicts. Use a day planner, your phone, or an online calendar to keep track of appointments and activities.\n- Be aware of your limits. If you do not have the time, energy, or interest, it is okay to politely decline when people ask you to take on tasks.\n- Ask for help. It is also good sense to ask family, friends, and coworkers for help.\n- Prioritize your tasks. Make a list of the things you routinely do, such as work and household chores.\n- Break down tasks into smaller steps. Sometimes large tasks can be done in smaller steps.\n- Concentrate your efforts on things you can control. A stressor may be something you cannot change or control, even with the best planning.\n- Get help with financial problems. Talk with an oncology social worker or a financial advisor who knows about cancer-related insurance and financial matters.".localaized, secondSubhead: "Stress management strategies".localaized, secondContent: "Although you can try to reduce the number of stressors in your life, you cannot completely avoid stress. The following are tips to help reduce stress:\n- Exercise regularly. Moderate exercise such as a 30-minute walk several times a week can help lower stress.\n- Spend time outside. If possible, take a walk outside in a park or other natural setting.\n- Schedule social activities. Make time to socialize with family or friends.\n- Eat well. Maintaining a healthy diet and getting enough rest will give you more energy to deal with daily stressors.\n- Get plenty of sleep. Life is busy and some people may think that sleep is indulgent.\n- Join a support group. Support groups offer you the chance to talk about your feelings and fears with others who share and understand your experiences.\n- Schedule daily relaxing time. Spend time doing an activity you find relaxing.\n- Do things you enjoy. Eat at your favorite restaurant or watch your favorite television show.".localaized, thirdSubhead: "Relaxation techniques".localaized, thirdContent: "Many people learn and practice relaxation techniques to lower stress. You can learn most of them in a few sessions with a counselor. such as during a medical procedure:\n- Relaxed or deep breathing.\n- Mental imagery or visualization.\n- Progressive muscle relaxation.\n- Meditation.\n- Biofeedback.\n- Yoga.".localaized))
        
        listSession.append(SessionDetile.init(title: "Coping with Anger".localaized, imageSession: UIImage(resource: .Session4)!, definition: "Many people living with cancer experience anger. Often, the feeling arises when receiving a cancer diagnosis. But it can develop any time throughout treatment and survivorship.".localaized, firstSubHead: "Coping with anger".localaized, firstContent: "Anger is a natural emotional response. You do not need to feel guilt if you experience it. Anger is not bad. But some people deal with it and express it in unhealthy ways.\n Unhealthy expressions of anger\n \n * Unhealthy responses to anger include:\n- Avoiding expressing the difficult emotions.\n- Behaving in ways that hurt others or yourself.\n- Abusing alcohol or drugs.\n Unhealthy responses to anger can lead to depression. Learn more about the signs and symptoms of depression and how to find help.".localaized, secondSubhead: "* Healthy expressions of anger".localaized, secondContent: "Healthy anger management involves identifying the emotion and expressing it productively. Consider the following tips when you feel angry:\n- Recognize your anger. Sometimes people act out of anger without acknowledging the emotion's presence.\n- Consider which other feelings lie underneath the anger. Sometimes, people hide other painful feelings under their anger. And they might not even realize they are doing this. Some people feel more comfortable with anger than other feelings, like fear or sadness.\n- Avoid taking out your anger on others. Direct your anger at the cause of the feelings, not at other people.\n- Do not wait for anger to build up. Express your feelings as soon as you recognize them. If you hold them in, you are more likely to express anger in an unhealthy way.\n Find safe ways to express your anger. You can express and release your anger in a number of healthy ways:\n- Discuss the reasons for your anger with a trusted family member or friend.\n- Do a physical activity while feeling your anger at its full intensity.\n- Beat on a pillow with your fists, or find a punching bag.\n- Yell out loud in a car or private room.\n- Explore complementary therapies, such as massage, relaxation techniques, music, or art".localaized, thirdSubhead: "Considering counseling.".localaized, thirdContent: "Many people benefit from counseling, either on their own or in a group setting.\n- Things you can accomplish with a mental health professional include:\n- Finding out what triggers your anger.\n- Avoiding destructive responses.\n- Finding healthy ways to express your feelings.\n- Learning valuable coping skills.\n- Addressing related issues, such as addiction or relationship problems.\n- A counselor can also evaluate whether chronic anger is contributing to clinical depression.".localaized))
        
        listSession.append(SessionDetile.init(title: "Anxiety".localaized, imageSession: UIImage(resource: .Session5)!, definition: "Anxiety may be described as feeling nervous, on edge, or worried. It is a normal emotion that alerts your body to respond to a threat. But intense and long-term anxiety is a disorder. It may interfere with your daily life and relationships.".localaized, firstSubHead: "Anxiety and cancer".localaized, firstContent: "Many people with cancer have symptoms of anxiety. A cancer diagnosis may trigger these feelings:\n- Fear of treatment or treatment-related side effects.\n- Fear of cancer returning or spreading after treatment.\n- Uncertainty.\n- Worry over losing independence.\n- Concern about having relationships change.\n- Fear of death.\n \n Anxiety may make it harder to cope with cancer treatment. It may also reduce your ability to make choices about your care. As a result, identifying and managing anxiety are important parts of cancer treatment. \n * Acute anxiety symptoms.\n You may often experience short periods of the symptoms listed below. A panic attack is when a person has all of these symptoms at once:\n- Feeling intense fear or dread.\n- Feeling detached from yourself or your surroundings.\n- Heart palpitations or rapid heartbeat.\n- High blood pressure.\n- Chest pain.".localaized, secondSubhead: "Chronic anxiety symptoms".localaized, secondContent: "Chronic anxiety typically last for a longer time. They may include acute anxiety episodes along with 1 or more of the symptoms below:\n- Excessive worrying.\n- Restlessness.\n- Muscle tension.\n- Insomnia, which is not being able to fall or stay asleep.\n- Irritability.\n- Fatigue.\n- Difficulty concentrating.\n- Indecision, which is having trouble making decisions.\n \n * Risk factors for anxiety. \n People with cancer are more likely to feel anxiety if they have these risk factors:\n - Previous diagnosis of anxiety or depression.\n- Family history of anxiety or depression.\n- Lack of support of friends or family.\n- Financial burdens".localaized, thirdSubhead: "Treatment types".localaized, thirdContent: "There are a variety of ways to cope with anxiety. Many are used together.\n- Relaxation techniques. Relaxation techniques may be used alone or along with other types of treatment.\n- Psychological Treatment. Mental health professionals include licensed counselors, psychologists, and psychiatrists. They provide tools to improve coping skills, develop a support system, and reshape negative thoughts. Options include individual therapy, couples or family therapy, and group therapy.\n- Medication. If your anxiety symptoms are moderate to severe, you may benefit from medication. Different types of medications are available.".localaized))
        
        listSession.append(SessionDetile.init(title: "Depression".localaized, imageSession: UIImage(resource: .Session6)!, definition: "Some people with cancer may experience depression before, during, or after cancer treatment. Depression is a type of mood disorder. It may make it harder to cope with cancer treatment.".localaized, firstSubHead: "Mood-related symptoms".localaized, firstContent: "- Feeling down.\n- Feeling sad.\n- Feeling hopeless.\n- Feeling irritable.\n- Feeling numb.\n- Feeling worthless.\n \n * Behavioral symptoms:\n- Loss of interest in activities that you used to enjoy.\n- Frequent crying.\n- Withdrawal from friends or family.\n- Loss of motivation to do daily activities.\n \n * Cognitive symptoms:\n- Trouble focusing.\n- Difficulty making decisions.\n- Memory problems.\n- Negative thoughts. In extreme situations, these may include thoughts that life is not worth living or thoughts of hurting yourself.".localaized, secondSubhead: "Physical symptoms".localaized, secondContent: "- Fatigue.\n- Appetite loss.\n- Insomnia, which is not being able to fall asleep and stay asleep.\n- Hypersomnia, which is feeling very sleepy most of the time.\n- Sexual problems, such as lower sexual desire. \n The cognitive and physical symptoms listed above may be side effects of the cancer or cancer treatment. As a result, doctors place more emphasis on mood-related and behavior symptoms when diagnosing depression in a person with cancer.\n * Risk factors for depression.\n People with cancer are more likely to have depression if they have these risk factors:\n- Previous diagnosis of depression or anxiety.\n- Family history of depression or anxiety.\n- Lack of support from friends or family.\n- Financial burdens".localaized, thirdSubhead: "Treatment of depression".localaized, thirdContent: "People with depression usually benefit from specialized treatment. For people with moderate or severe depression, a mix of psychological treatment and medication is often the most effective approach. For some people with mild depression, talking with a mental health professional may be enough to relieve depressive symptoms.\n- Psychological treatment. Mental health professionals include licensed counselors, psychologists, and psychiatrists.\n- Options include individual therapy, couples or family therapy, and group therapy.\n- Medications. Different types of antidepressant medications are available. Your doctor will select the most appropriate antidepressant based on these factors:\n- Your needs, Potential side effects, Other medications you take, and Your medical history.".localaized))
        
        listSession.append(SessionDetile.init(title: "Managing the Fear".localaized, imageSession: UIImage(resource: .Session7)!, definition: "It is normal to be afraid of side effects when you start cancer treatment. You may have heard stories from family and friends who have had cancer about their experiences.".localaized, firstSubHead: "How can I cope with my fears of side effects?".localaized, firstContent: "Remember that the long-term goal of treatment is to help you, not hurt you. Many cancer treatments used today are less intense and take less time than in the past. And many side effects last only a short time in general.\n Here are some tips for coping with the fear of side effects.\n- Take an active role in your treatment planning, also called shared decision making. These conversations with your doctor should include possible side effects of different treatment approaches.\n- Ask when to expect which side effects during and after your treatment period so you know what to watch for and won't be surprised if they occur.\n- Ask a member of your cancer care team for a list of possible symptoms that may require immediate medical care.\n- Write down all of your questions and concerns, no matter how big or small, including ones that you may have heard from a friend or family member.\n- Communicate often. Let your doctor, nurse, and other providers know what you're thinking and experiencing so they can help.".localaized, secondSubhead: "Talking about your fear of cancer side effects".localaized, secondContent: "In addition to talking with your cancer care team, it can be helpful to communicate with others too. Talk with your family and loved ones about your fear of side effects and other worries. Their support can make you feel less anxious and your loved ones can better understand your feelings. Be sure to share information provided by your health care team about what to expect. Together, you can think through possible caregiving needs and solutions or other plans.\n \n You might want to talk with your supervisor or human resources person at your workplace about your treatment and possible side effects. This conversation may cover how you can adjust your schedule during treatment if you need to.\n Ask your cancer care team about meeting with a social worker who can help you navigate these types of conversations. It can also help to talk to someone who has been through the same type of treatment you will go through.".localaized, thirdSubhead: "Questions to ask the health care team".localaized, thirdContent: "- What symptoms can I expect from this specific type and stage of cancer?\n- What side effects are common from each treatment in my cancer treatment plan?\n- When is it likely that side effects will occur? How long will they last?\n- Is there anything I can do to prepare for these side effects?\n- What can the health care team do to prevent or relieve side effects?\n- Who should I tell if I begin experiencing side effects from treatment? How soon?\n- What side effects or symptoms are considered emergencies?\n- Who do I contact if I have questions about a side effect? Who can I contact after hours when the clinic is closed?".localaized))
        
        listSession.append(SessionDetile.init(title: "Coping with Guilt".localaized, imageSession: UIImage(resource: .Session8)!, definition: "Many people living with cancer experience guilt. Guilt is a feeling of blame and regret that is usually hard to accept and express.".localaized, firstSubHead: "", firstContent: "Many people living with cancer experience guilt. Guilt is a feeling of blame and regret that is usually hard to accept and express. Guilt often leads people to replay 'what if' and 'if only' scenarios in their minds to figure out what they could have done differently.\n People with cancer may feel guilt at various times for different reasons. For example, you may feel guilty because:\n- You could have noticed symptoms earlier or gone to the doctor sooner.\n- You worry that you are a burden to your family or caregivers.\n- The treatment you received did not work the way you had hoped.\n- The cancer comes with financial costs or causes you to spend time away from work for treatment.\n- You survived cancer while others did not. This is also called “survivor’s guilt.”\n- You blame yourself or feel embarrassed or ashamed of lifestyle choices and habits that may have increased your risk of developing cancer.".localaized, secondSubhead: "Coping with guilt".localaized, secondContent: "Feelings of guilt are common, but it is not healthy to keep thinking about them. Feeling very guilty about events outside of your control and not being able to let go of guilt can lead to depression. Although depression is more common among people with cancer, it should not be considered a normal part of living with cancer.".localaized, thirdSubhead: "Letting go of guilt".localaized, thirdContent: "Letting go of guilt can help improve your well-being and your ability to cope with cancer. Consider the following tips to reduce guilty feelings:\n- Remember that cancer is not your fault—or anyone else’s. Experts do not fully understand why most types of cancer develop. Sometimes people with cancer feel guilty about specific lifestyle choices they made, such as cigarette smoking.\n- Know that your feelings of guilt will come and go. Just like all difficult emotions triggered by a diagnosis of cancer, your feelings of guilt will change over time.\n- Share your feelings. Talk about the guilt you are feeling with someone you trust or with a counselor or social worker.".localaized))
        
        listSession.append(SessionDetile.init(title: "Coping with Cancer".localaized, imageSession: UIImage(resource: .Session9)!, definition: "Metastasis occurs when cancer spreads to a different part of the body from where it started. Metastasis should not be confused with “locally advanced cancer.” That is cancer that has spread to nearby tissues or lymph nodes.".localaized, firstSubHead: "Naming metastatic cancer".localaized, firstContent: "You may find the naming of metastatic cancer confusing. Doctors name a metastasis for the original cancer. For example, breast cancer that spreads to the bone is not bone cancer. It is called metastatic breast cancer. \n * What does it mean to have metastatic cancer?\n In the past, many people did not live long with metastatic cancer. Even with today’s better treatments, recovery is not always possible. But doctors can often treat cancer even if they cannot cure it. A good quality of life is possible for months or even years.\n * How is metastatic cancer treated?\n Treatment depends on the type of cancer, the available treatment options, and your wishes. It also depends on your age, general health, treatment you had before, and other factors. Treatments for metastatic cancer include surgery, chemotherapy, hormone therapy, immunotherapy, and radiation therapy.".localaized, secondSubhead: "Goals of treatment".localaized, secondContent: "For many people with cancer, the goal of treatment is to try to cure the cancer. This means getting rid of the cancer and never having it come back. With metastatic cancer, curing the cancer may not be a realistic goal. However, it might still be a hope or dream. It is reasonable to ask your doctor if curing the cancer is the goal.\n \n If curing the cancer is not the goal of treatment, the goal is to help a person live as well as possible for as long as possible. Getting more specific, this goal can be broken into 4 parts:\n- To have the fewest possible side effects from the cancer.\n- To have the fewest possible side effects from the cancer treatment.\n- For the person with cancer to have the best quality of life.\n- For the person with cancer to live as long as possible with the cancer.\n Each person values these items differently. It is important to tell your health care team what is important to you.\n Getting treatment for metastatic cancer can help you live longer and feel better. But getting treatment is always your decision.".localaized, thirdSubhead: "The challenges of living with cancer".localaized, thirdContent: "Living with metastatic cancer is challenging. The challenges are different for everyone, but they can include:\n- Feeling upset that the cancer came back. You might feel hopeless, angry, sad, or like no one understands what you are going through, even family.\n- Worrying that treatment will not help and the cancer will get worse.\n- Dealing with tests, doctor’s appointments, and decisions.\n- Talking with family and friends about the cancer.\n- Needing help with daily activities if you feel exhausted or have side effects from treatment.\n- Finding emotional and spiritual support.\n- Coping with the cost of more treatment. Even if you have insurance, it might not cover everything.".localaized))
    }
}
