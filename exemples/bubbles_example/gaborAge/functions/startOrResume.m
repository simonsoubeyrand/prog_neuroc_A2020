function params = startOrResume(params)

resultsDir = params.resultsDir;
logfiles = get_files(resultsDir,'*run*.txt');

% check to remove any training runs
if not(isempty(logfiles))

    params.runI = size(logfiles,1)+1;
else
    params.runI = 1;
end





