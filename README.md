# ARIA-Win-cmd-AI
My biggest project yet, ARIA is a free Windows CMD AI assistant for general knowledge and creative writing. Powered by Ollama, it runs open-source models entirely on your PC — no API key, no subscription, no internet after setup. Features auto-saved conversation logs, model switching, and session history. Just double-click and chat.

  A R I A  
  AI General & Writing Assistant  
  Powered by Ollama  |  Free  |  Offline  |  No API Key  
 


ARIA is a standalone Windows CMD AI assistant for general knowledge and creative writing. It runs open-source AI models entirely on your PC using Ollama — no internet after setup, no subscriptions, no accounts.
Overview
ARIA (AI Response & Intelligence Assistant) is a single .bat file that turns your Windows Command Prompt into a capable AI assistant. It supports general Q&A, creative writing, summarisation, brainstorming, and more — all running locally on your machine.

Feature	Detail
File	ARIA.bat
AI Engine	Ollama (free, open-source)
Default Model	Mistral (~4 GB, one-time download)
Internet Required	Only for first-time model download
API Key Required	No
Cost	Free forever
History Logging	Auto-saved to logs\ folder by date

System Requirements
Component	Minimum	Recommended
Operating System	Windows 10 64-bit (build 1903+)	Windows 11 64-bit
RAM	8 GB	16 GB or more
Disk Space	5 GB free per model	10+ GB free
GPU	Not required (CPU only)	Any modern GPU (3-10x faster)
curl	Built into Windows 10/11	Built into Windows 10/11
Ollama	Required (free installer)	Latest version

Setup & Installation
Step 1 — Install Ollama
Ollama is a free tool that downloads and runs open-source AI models locally on your PC.

1.	Open your browser and go to:
https://ollama.com/download
2.	Download the Windows installer and run it.
3.	Follow the on-screen instructions. No account or sign-up is needed.

If Ollama is not installed, ARIA will detect this automatically and open the download page for you.

Step 2 — Run ARIA
4.	Place ARIA.bat anywhere on your PC (Desktop, Documents, etc.).
5.	Double-click ARIA.bat — or right-click and choose Open.
6.	On first launch, ARIA will automatically download the Mistral model (~4 GB). This is a one-time download. After this, ARIA works fully offline.

You can also run ARIA from an existing Command Prompt window by navigating to its folder and typing: ARIA.bat

Using ARIA
Main Menu
When ARIA opens, you will see the main menu with five options:

Option	Action
1  New Chat	Start a fresh conversation with the AI
2  View Session History	Review messages from the current session
3  Browse Saved Logs	Open and read past conversation log files
4  Change Model	Switch to a different downloaded AI model
5  Exit	Close ARIA

Chatting with ARIA
In the chat window, simply type your message and press Enter. ARIA will respond within a few seconds depending on your hardware.

Example Prompts — General
•	Explain how black holes form in simple terms
•	What are the pros and cons of electric vehicles?
•	Give me a recipe for a quick pasta dish
•	What happened during the French Revolution?

Example Prompts — Writing
•	Write a short story about a lighthouse keeper in a storm
•	Rewrite this paragraph in a more formal tone: [paste text]
•	Give me 5 catchy headline ideas for an article about remote work
•	Summarise this in 3 bullet points: [paste text]
•	Write a professional email declining a meeting invitation

In-Chat Commands
Command	What it does
/help	Show the help panel with tips and example prompts
/history	Print all messages from the current session
/clear	Reset the conversation context (start fresh without exiting)
/save	Display the path to the current log file
/quit	End the chat and return to the main menu
/exit	Close ARIA completely

History & Log Files
ARIA automatically saves every conversation to a log file. No manual saving is needed.

Item	Detail
Log folder	logs\  (created automatically next to ARIA.bat)
Filename format	history_YYYY-MM-DD.txt
When saved	After every single message — auto-saved continuously
What is saved	Timestamps, your messages, and ARIA's replies
View in app	Main Menu > Option 3 (Browse Saved Logs)

Log files are plain text and can be opened in any text editor such as Notepad. They are stored locally on your PC and never sent anywhere.

AI Models
ARIA defaults to Mistral, which is an excellent all-purpose model. You can switch models from the main menu at any time.

Model	Size	Speed	Best For
mistral	~4 GB	Fast	Default — great all-rounder for chat and writing
llama3	~4 GB	Fast	Meta's flagship open model, strong reasoning
phi3	~2 GB	Very fast	Lower-spec PCs, quick responses
gemma2	~5 GB	Moderate	Google's open model, strong at analysis
tinyllama	~600 MB	Fastest	Very old hardware, minimal responses

To manually download a model outside of ARIA, open any Command Prompt and run:
ollama pull phi3

Models only need to be downloaded once. After that they are stored on your PC and available offline permanently.

Known Limitations
•	Special characters (%, ^, <, >, |) are intercepted by Windows CMD and may behave unexpectedly in input.
•	Very long AI responses may be truncated due to batch string length limits. This is a Windows CMD limitation, not an Ollama limitation.
•	The conversation context passed to the model is limited to the last 6 exchanges to keep performance fast. Use /clear to reset if responses feel off-topic.
•	Response speed depends entirely on your hardware. A GPU significantly improves generation speed.

Quick Reference
Task	How
Launch ARIA	Double-click ARIA.bat
Install Ollama	https://ollama.com/download
Download a model	ollama pull <modelname>  in any CMD window
List installed models	ollama list  in any CMD window
Start a new chat	Main Menu > 1
View today's log	Main Menu > 3, then type the filename
Reset conversation	Type /clear in chat
Switch AI model	Main Menu > 4
Get help in chat	Type /help
Exit ARIA	Type /exit  or  Main Menu > 5


ARIA  |  Free  |  Local  |  No API Key  |  Powered by Ollama
