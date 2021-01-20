# judgement_bias_task_analysis
Judgement bias task analysis

This repository is used for cleaning and analysing data created as output of the KLimbic software, which manages the run of a decision-making task on operant chambers. The task is called judgement bias task and involves decisions between both learnt cue-action-outcome associations and novel or ambiguous ones.

An initial goal was to gather all available data from this task as run by people in the Robinson psychopharmacology lab in the University of Bristol, so that high N number analysis can be performed and a clearer picture of what is happening during the task is produced. To achieve this, this repository receives raw CSV data (output of the KLimbic operant manager), discards unnecessary metadata and aberrant decision trials (e.g. those happening very quickly, where we hypothesise that the subject was not paying attention to the presented cue) and transforms the data to a common structure format, including subject ID, response times, decisions and their outcomes.

At a second stage, analysis is performed on these structures. This step involves on-going work!
