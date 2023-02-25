function varargout = cloth_glove_detection(varargin)
% CLOTH_GLOVE_DETECTION MATLAB code for cloth_glove_detection.fig
%      CLOTH_GLOVE_DETECTION, by itself, creates a new CLOTH_GLOVE_DETECTION or raises the existing
%      singleton*.
%
%      H = CLOTH_GLOVE_DETECTION returns the handle to a new CLOTH_GLOVE_DETECTION or the handle to
%      the existing singleton*.
%
%      CLOTH_GLOVE_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLOTH_GLOVE_DETECTION.M with the given input arguments.
%
%      CLOTH_GLOVE_DETECTION('Property','Value',...) creates a new CLOTH_GLOVE_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cloth_glove_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cloth_glove_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cloth_glove_detection

% Last Modified by GUIDE v2.5 22-Dec-2022 20:08:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cloth_glove_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @cloth_glove_detection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before cloth_glove_detection is made visible.
function cloth_glove_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cloth_glove_detection (see VARARGIN)

% Choose default command line output for cloth_glove_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cloth_glove_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cloth_glove_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
cla reset;
[File_Name, Path_Name] = uigetfile({'D:\Degree 3 - Image Processing\dataset\*.jpg*'},'Select image');
fullname = fullfile(Path_Name,File_Name);
im = imread(fullname);
axis(handles.axes1);
imagesc(im);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)

    input = get(handles.axes1,'Children');

    % Get the image data from the object
    im = get(input, 'CData');

     % Get the value of the pop-out menu
     if isempty(input)
            % Display an error message if the axes is empty
            errordlg('Error: You did not load image!','Error Message','modal');
     else
        clothcover = cloth_glove_identifier(im);
        if (clothcover >= 30)

            switch get(handles.popupmenu1, 'value')
                case 1
                    % color image segmentation
                    OSxh = rgb2hsv(im);
                    OSR= OSxh(:,:,1);
                    OSG = OSxh(:,:,2)*2.5; 
                    OSB = OSxh(:,:,3);
                    
                    [OSH,OSS,OSI] = rgb2hsv(OSR,OSG,OSB);
                    
                    OSSh = ((OSH>1)+(OSH<0.5))>0;
                    OSShnobord = imclearborder(OSSh,4);
                    OSEh = double(bwmorph(OSShnobord,'erode',3));
                    OSDh = double(bwmorph(OSEh,'dilate',5));
                    OSBWnobord = imclearborder(OSDh,4);
                    
                    
                    
                    [OSBBox, numRegions] = bwlabel(OSBWnobord);
                    BWfinal = regionprops(OSBBox, 'BoundingBox');
    
                    axis(handles.axes1);
                    imagesc(im);
                    hold on;
                    % Plot the bounding box around each region.
                    for k = 1 : numRegions
                        OSthisBBox = BWfinal(k).BoundingBox;
                        rectangle('Position', OSthisBBox, 'EdgeColor', 'r','LineWidth',1);
                        break
                    end
                case 2
                    % Tearing detection
                    % color image segmentation
                    TRxh = rgb2hsv(im);
                    TRR= TRxh(:,:,1);
                    TRG = TRxh(:,:,2)*2.5;
                    TRB = TRxh(:,:,3);
                    
                    
                    TRSh = ((TRG>1)+(TRG<0.58))>0;
                    TRbw2 = imcomplement(TRSh);
                    TRbw2clearbord = imclearborder(TRbw2,4);
                    TRse90 = strel('line',3,90);
                    TRse0 = strel('line',3,0);
                    TRBWsdil = imdilate(TRbw2clearbord,[TRse90 TRse0]);
                    
                    TREh = double(bwmorph(TRBWsdil,'erode',1));
                    TRDh = double(bwmorph(TREh,'dilate',10));
                    TRBWnobord = imclearborder(TRDh,4);
    
                    [BBox, numRegions] = bwlabel(TRBWnobord);
                    
                    BWfinal = regionprops(BBox, 'BoundingBox');
                    
                    axis(handles.axes1);
                    imagesc(im);
                    hold on;
                    % Plot the bounding box around each region.
                    for k = 1 : numRegions
                        thisBBox = BWfinal(k).BoundingBox;
                        rectangle('Position', thisBBox, 'EdgeColor', 'r','LineWidth',1);
                        break
                    end
                case 3
                    STxh = rgb2hsv(im);
                    STR= STxh(:,:,1);
                    STG = STxh(:,:,2)*5;
                    STB = STxh(:,:,3);
                    
                    
                    [STH,STS,STI] = rgb2hsv(STR,STG,STB);
                    
                    STSbw = im2bw(STS,graythresh(STS));
                    STSbw2 = imcomplement(STSbw);
                    STEh = double(bwmorph(STSbw2,'erode',2));
                    STDh = double(bwmorph(STEh,'dilate',7));
                    STSBWdfill = imfill(STDh,'holes');
                    STSbwfinal = imcomplement(STSBWdfill);
                    
                    STHBW = im2bw(STH);
                    
                    
                    STfinalimage = STSbwfinal & STHBW;
                    
                    
                    STEh = double(bwmorph(STfinalimage,'erode',3));
                    
                    STDh = double(bwmorph(STEh,'dilate',7));
                    
                    STBWnobord = imclearborder(STDh,4);
                    
                    [BBox, numRegions] = bwlabel(STBWnobord);
                    BWfinal = regionprops(BBox, 'BoundingBox');
                    axis(handles.axes1);
                    imagesc(im);
                    hold on;
                    % Plot the bounding box around each region.
                    for k = 1 : numRegions
                        thisBBox = BWfinal(k).BoundingBox;
                        rectangle('Position', thisBBox, 'EdgeColor', 'r','LineWidth',1);
                        break
                    end
                otherwise
            end
        else
            errordlg('The image given is not a cloth glove', 'Error Message','modal');            
        end
     end
    
% 
%     input = get(handles.axes1,'Children');
%     To let it to be readable as what we read from imread function
%     % Get the image data from the object
%     input_image = get(input, 'CData');


% if(strcmp(pop_choice,'open seam ')) 
%     
% 
% elseif(strcmp(pop_choice,'Tearing '))
% 
% elseif((strcmp(pop_choice,'Stitching run off ')))
% 
% else
% end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % Close the first GUI
    close(cloth_glove_detection);
    
    % Create and display the second GUI
    GDD();
