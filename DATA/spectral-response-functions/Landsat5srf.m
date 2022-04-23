function srf = Landsat5srf(workbookFile, sheetName,  band)
%IMPORTFILE1 Import data from a spreadsheet
%  L5TMRSR = IMPORTFILE1(FILE) reads data from the first worksheet in
%  the Microsoft Excel spreadsheet file named FILE.  Returns the data as
%  a table.
%
%  L5TMRSR = IMPORTFILE1(FILE, SHEET) reads from the specified worksheet.
%
%  L5TMRSR = IMPORTFILE1(FILE, SHEET, DATALINES) reads from the
%  specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  L5TMRSR = importfile1("F:\camryn\SL2PD-master\DATA\spectral-response-functions\L5_TM_RSR.xlsx", "Spectral Response (Landsat 5)", [2, 2302]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 08-Jul-2020 17:56:33

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end


    dataLines = [2, 2302];
%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 7);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":G" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["SR_WL", "Landsat5_SR_AV_B1", "Landsat5_SR_AV_B2", "Landsat5_SR_AV_B3", "Landsat5_SR_AV_B4", "Landsat5_SR_AV_B5", "Landsat5_SR_AV_B7"];
opts.SelectedVariableNames = ["SR_WL", "Landsat5_SR_AV_B1", "Landsat5_SR_AV_B2", "Landsat5_SR_AV_B3", "Landsat5_SR_AV_B4", "Landsat5_SR_AV_B5", "Landsat5_SR_AV_B7"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double"];

% Import the data
data = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":N" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    data = [data; tb]; %#ok<AGROW>
end

response = data.(['Landsat5_SR_AV_',band]);
srf.lambda  = data.SR_WL(find(response>0, 1,'first'):find(response>0, 1,'last'));
srf.sensi = response(finsave d(response>0, 1,'first'):find(response>0, 1,'last'));
srf.begin_mode_end = [min(srf.lambda),srf.lambda(find(srf.sensi==max(srf.sensi),1,'first')) max(srf.lambda)];


end