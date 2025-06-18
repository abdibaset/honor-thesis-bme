function sortedFolders = sortedFoldersByNumber(acqFolders)
    %Sorts folder structs by the leading numbers of the name 
    % example folder 001213_01, 001214
    fnum = zeros(1,numel(acqfolders));
    for a = 1:numel(acqfolders)
        str_fld = strsplit(acqfolders(a).name,'_');
        fnum(a) = str2double(str_fld{1});
    end
    [~,ind] = sort(fnum);
    sortedFolders = acqfolders(ind);
end 
    