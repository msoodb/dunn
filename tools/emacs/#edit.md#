A beginner’s guide to text editing with Emacs
November 27, 2019Tara Gu4-minute read

Share

Subscribe

    Back to all posts 

Emacs is a text editing tool that comes out-of-the-box with Linux and macOS. As a (less popular) cousin of Vim, Emacs also offers powerful capabilities with easy-to-install language support, and can even help you navigate faster in macOS with the same keybindings. If you want to know why you should learn Emacs and how to get started, please keep reading.
Emacs vs. Vim

If you are new to text editing, you may wonder if you should go with Emacs or Vim, since remembering all of the commands for either can involve a significant investment of muscle memory. There’s a dedicated Wikipedia page with a summary of the differences and pros vs. cons to help you decide what side of the editor war between Vim and Emacs you’re on.

One of the most notable differences between is two editors is that, unlike Emacs, Vim has two modes: Insert mode (where you can edit the file and cannot enter commands) and Command mode (where you can only enter commands and the file is read-only). Because Emacs is modeless, its keyboard commands often start with the Ctrl key or the Meta key (which can be Esc or Opt if configured in your macOS terminal preferences), so that the system can distinguish actual edits from commands. In my experience, Emacs resembles editors like Microsoft Word and Google Docs more than Vim because of its modelessness, and this fact may make it easier to get used to than Vim.

As noted in the Wikipedia editor war article, the "non-modal nature of Emacs keybindings makes it practical to [use them as] OS-wide keybindings." This sentiment summaries the biggest reason that I choose Emacs over Vim. As an Apple addict, many of the Emacs keyboard shortcuts come out-of-the-box with macOS, such as: 
Ctrl+A
	Go to the beginning of the line.
Ctrl+E
	Go to the end of the line.
Meta+Delete
	Delete the last word before the cursor.
Ctrl+F
	Go forward by one letter.
Ctrl+B
	Go back by one letter.
Ctrl+K
	Delete the rest of the current line starting from the cursor.


Note: Whether you use capital or lowercase letters does not matter in this case.

This setup makes navigating any text field faster in tools such as browsers and Google Docs. 

Emacs vs. IDEs

There’s the ancient question of whether text editors or IDEs (e.g., the JetBrains suite or Eclipse) are better for everyday coding activities. Everyone has different preferences, and the best way for you to find yours is to try both. You may find out that a hybrid approach works best for you.

How well a text editor works depends on the plugin support for the specific language you're using. Furthermore, many IDEs may not work well for certain languages. For example, for a scripting language like Python, go-to-definition and finding usage does not work well with most IDEs I’ve tried (such as JetBrains' PyCharm) because of poor indexing. As a result, my default tool of choice when developing in Python is Emacs, as a simple rgrep will do the job for finding usage.

On the other hand, a strongly typed language like C++ or Java makes a good IDE shine like nothing else. I have not had a good experience with go-to-definition in Emacs when working with C++, especially when there are multiple levels of virtualness and overloaded functions. Out of all of the IDEs I’ve tried, the JetBrains suite (Goland for Golang, IntelliJ for Java, and CLion for C/C++) in my opinion works best for object-oriented programming. The downside is that the JetBrains suite does have a larger CPU and memory footprint, as it’s constantly processing your project code and its dependencies in the background (hence the close-to-perfect indexing), and many of the JetBrains products are not free (such as Goland).

If you decide to go with an IDE, you can still keep your Emacs command muscle memory, because you can use the same key bindings when navigating in the IDE. For the JetBrains suite, you can:

    Go to the menu bar.
    Select Goland -> Preferences -> Keymap
    Select Emacs from the dropdown menu.

A good IDE makes reading a large project’s code easier. However, when it comes to coding, it’s important to note that my editing experience is not quite the same in JetBrains Goland even though I’ve set up Emacs keybindings. Completely mouse-free coding is not achievable with an IDE, so when I’m focused on developing one piece of logic, I still fire up good old Emacs.
Summary

Different text editors have their own strengths and weaknesses, and how well they work can vary a lot between individuals. Emacs works for me because I can reuse many of the same shortcuts with macOS. In my day-to-day development within Golang, I use a combination of JetBrains' Goland and Emacs. If you are not too deeply invested in Vim, I encourage you to give Emacs a try.
