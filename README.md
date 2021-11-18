# Winlogbeat Powershell Ingestor (Cold Logs) for Elastic Stack

Winlogbeat in Elastic Stack is inevitably extremely useful for Forensic Analysis. However, one fatal flaw in its design lies within its configuration to only capture hot logs (logs generated immediately). In forensic analysis, we usually deal with cold logs (logs generated previously). To maximise the benefits of the winlogbeat, I ploughed through the internet for resources to direct winlogbeat to ingest cold logs instead - and these were the compiled source files (amended to my use case) which worked for me. 

*These customisations are only meant for .evtx files 

Before proceeding, do set up your Elastic Stack instance first.

Instructions for use: 
1. Download the code files and place it your "Program Files" directory right underneath your C Drive. 
2. In "elk-events/winlogbeat/winlogbeat-events.yml", edit the elasticsearch host to where your Elasticsearch instance is running on. 
3. Open up an ELEVATED powershell terminal and enter the relocated directory. 
4. Run winlogbeat on the edited yml file using this command 
        ./winlogbeat -c winlogbeat-events.yml -e
5. Enter the following command to start winlogbeat
        Start-Service winlogbeat
6. Go back to your file location and clack "winlogbeat-evtx". Run it with powershell.
7. Based on the commands, enter your file location. This can also be a directory - it will merely ingest every single file under that directory. 
8. Go back to Kibana on your browser. You should see the files being ingested. 

Here are the links to the official winlogbeat documentation: 
[Quick start](https://www.elastic.co/guide/en/beats/winlogbeat/7.13/winlogbeat-installation-configuration.html) guide.

## Official Documentation

Visit [Elastic.co Docs](https://www.elastic.co/guide/en/beats/winlogbeat/7.13/index.html)
for the full Winlogbeat documentation.