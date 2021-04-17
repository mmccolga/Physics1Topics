# SienaARPrimaryApp
An educational mixed reality application for teaching students complex topics in fields of science.


# What is Git and Github?

  Git is a version control system for computer terminals. Git tracks a directory called a
  repository and the user can specify what files in that directory can be saved in the cloud.
  When a user "clones" a git repository they can start running commands to make changes to the
  files in the cloud so that other team members can "pull" the changes on their local devices.
  
  Github is simply a website to view and manage your Git profile and repositories.
  

# Setup Instructions:

Make an account at https://github.com

Here is a video tutorial to install git, along with cloning repos, and making changes. https://www.youtube.com/watch?v=HVsySz-h9r4

Windows:
  Open Git Bash or prefered terminal.
    
MacOS:
  Open Terminal (You can spolight search or find in launchpad).
  
* At 4:13 in the video, you learn how to configure your github profile with git.

** At 15:10 in the video, you learn how to clone a repo. Watch before doing the next steps so that it is clear.

'cd' into a directory of your choice, (I use Documents) then run the following commands:
- mkdir /UnityProjects       
- cd /UnityProjects
- git clone https://github.com/SienaUnityXRApps/SienaARPrimaryApp
- cd SienaARPrimaryApp
- git status            (this will give the status of the repository and may give you further instruction.)

Close the terminal.

Open Unity Hub.
Click Add in the Projects screen.
Locate our /UnityProjects/SienaARPrimaryApp repo directory.
Open the project with Unity version 2019.4.21f1.  (Install it if you do not have it already.)
Do not update Vuforia if it prompts you to do so. (It probably will... all the time.)
  
Congrats, you've cloned the Siena Primary App for Physcis simulations!

# Updating and Uploading:

  Before making local changes, always do a 'git pull' to make sure you have all the changes in the cloud.
  
  After adding a new Scene or any GameObject or Script, you will need to use the terminal to 'git add filename' to track that file.
  If you added many files, 'git status' will show you all the untraked files you need to add.
  If you agree with all the files it is saying to add, you can run 'git add --all'
  Otherwise add them one by one with 'git add filename' (Note that the file will likely need its path as well - Assets/Example/Blah/Blah/filename)
  
  Any file that is already tracked and you have modified will require a 'git commit -m "message stating what you did to it'.
  When you add/track a new file, that requires a commit as well.
  You can choose to 'git commit -am "message generalizing all the changes you made" to commit all your changes with one message in one command.
  
  Once all your files are added/tracked and commited run 'git push' to upload them.
  
  Generally, 'git pull' before you start working, then make all your changes to the project you want.
  Run 'git status' to check all the changes you made.
  Assuming everything looks right (delete unwanted files if need be, or 'git restore filename' if you didnt mean to modify it),
  run 'git add --all'
  then 'git commit -am "message generalizing all the changes you made"
  then finally 'git push'
  
  If you ever get stuck in a screen saying "merge request message"
  Don't do anything except type ':wq' on the keyboard. That will make that screen go away. (That stands for write and quit if that helps you remember)

More Git Commands:
https://confluence.atlassian.com/bitbucketserver/basic-git-commands-776639767.html
