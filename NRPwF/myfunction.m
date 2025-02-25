function output = myfunction(shifttimes,timestamp)
output=sum(shifttimes>timestamp);
output=mod(output,2);
end