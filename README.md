#How to use this repository

This repository will projects that I have worked on over the past 
few years. It will mostly consist of scritping languages as those
sort of languages were the best tools for the jobs.

Each section will have a link to the project that is being discussed
and will contian breif description of the goals and aims of said project.

Most of the projects I have worked on stem from the curiosity of downloading
data from external sources or small utility programs that I have worked on with
the goal of making my life easier.

The final seciton of this document will go over some technologies that I have
become familiar over the years. 

#[Govison](../GoVision)
This project was created for my final year dissertation submission. The
main aim of this project was to prove that it is possible to extract data
from a game server such as Counter-Strike:Global Offensive, and apply some
analysis in a real time manner.
##Extracting the data
This project spanned a number of programming and scripting languages. 
Starting off in [Sourcepawn](https://wiki.alliedmods.net/Introduction_to_SourcePawn_1.7) a plugin was written to hook into a few game events 
and send over an encoded packet to the processing server. This took a rather
significant portion of development time as the API isn't well documented and a 
lot of trial and error was needed to get things off the ground.
##Processing the data
A server was written in C# to accept an incoming TCP/IP connection from
the plugin. Each packet would contain a 4 byte header followed by a body
size. This allowed for the easy ingestion for a incoming packet.

Once a packet was ingested it would be placed on a buffer queue. A separate
thread would read off the queue and parse out the packet. Each packet would
implement a IPacket interface which would allow it to run functions on the game
object. This implementation allowed for all packet types to be able to
manipulate the game object.

##Handling clients
Once the data has been collected the analyser thread would prepare a message
to be dispatched any webclients connected to it. To achieve this a dispatcher
pattern was used. The dispatcher object would have access to all the current
web sessions and would duplicate the outgoing message to each clients output buffer.
Each client thread would read from its buffer and send the message to the
connected websocket.

##[Web client](../GoVision/GoVisionWeb/)
Vanilla JS was used for all the rendering. The browser would attempt to connect
to the processing server via a websocket and once it has connected it would
listen to incoming messages. The messages were encoded in json this was purely 
done for the sake of simplicity. Each json message would have a **type** attribute.
This allowed for the filtering of different update messages.

When the browser intercepted a spray update it would receive multiple arrays 
of data. For example these would be the bullet time stamps and the camera pitch 
and yaw values with their corresponding time stamps.

These values would be used to plot the spray pattern on the screen and calculate the 
deviation from the nominal recoil control.

The calculations could have been moved over to the processing server but during the time
crunch it was decided that these calculation would be done on the client side.
This allowed for instant feedback during the development as the javascript 
could be live reloaded.

The only calculations done on the processing server would be the grouping of 
the shots and some code to patch together the yaw values as when the camera 
was panning there was a chance that it would cross the -180/180 boundary axis.
The code would check if that edge case occurred and would apply an offset to all
the values mitigating this from happening.

##Tooling
Some tools were written for this project. The main one that saved a lot of time
was the [run.ps1](../GoVision/tools/run.ps1) and [argsgen.py](../GoVision/tools/argsgen/main.py) as it allowed for the automatic generation 
of parameters for the game server executable. It would also copy over configuration 
files to the game server directory allowing for the easy management 
of testing environments.  

#[Networking project](../Networking/)
For this project I was tasked with creating a client and server to implement
the [whois](https://www.rfc-editor.org/rfc/rfc3912.txt) protocol. The server would manage accept incoming requests either in the basic request , http 1.0 and http 1.1 syntax and be able to provide the location of a 
resource or create/update the location of a resource. The client would be able to
send these requests with the option of using all three protocols.

#[BLM scraper](../blmscraper/)
I'll be honest this one is a bit weird one. I somehow stumbled upon [this](https://www.blm.gov/or/landrecords/survey/ySrvy1.php) website. 
It allows you to query the land deed records of plots of land in the 
washington and oregon are of the united states. I noticed that you can extract 
drop down values from the form (which has a mistake in). Using those values I was
able to write a python script to sequentially query their back end database for
the full dataset.

On the surface this project did seem a little out there but it did teach me a few
interesting things about how a html parsing library works and introduced me to the
[beautiful soup](https://www.crummy.com/software/BeautifulSoup/bs4/doc/) library. One of the more interesting things that I learned from the project 
is how different html parsing libraries handle malformed DOM elements. It turns out 
that the response sent by the website is missing closing <\/tr> tag. Turns out that 
that most modern parsing libraries, for example the chrome debugger tool, are able
to handle this gracefully and re insert the closing tag without letting you know there
was an issue in the first place. The basic python parsing library did not do that
which caused some minor loss in sanity when trying to debug the code.

Since then I have written a handful of project that are very similar in nature.
For example I needed some profile pictures for around 30 steam profiles. Instead of
manually downloading and naming them all I was able to repurpose older code 
to do this task automatically for me.

#Linux vm script
I typically run VM's on my machine when I need to test/develop in linux 
environment. However using the GUI to launch my vms was rathe cumbersome 
so I wrote a 2 powershell scripts that had the ability to list all registered
VM's on my machine (with fancy colouring) and to be able to start the VM's.

![vm script](../img/Powershell.png)
#Worst audio level changer

#Various powershell scripts

#Student app

#Knowlege overview
