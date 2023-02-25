function varargout = plastic_glove_detection(varargin)
% PLASTIC_GLOVE_DETECTION MATLAB code for plastic_glove_detection.fig
%      PLASTIC_GLOVE_DETECTION, by itself, creates a new PLASTIC_GLOVE_DETECTION or raises the existing
%      singleton*.
%
%      H = PLASTIC_GLOVE_DETECTION returns the handle to a new PLASTIC_GLOVE_DETECTION or the handle to
%      the existing singleton*.
%
%      PLASTIC_GLOVE_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLASTIC_GLOVE_DETECTION.M with the given input arguments.
%
%      PLASTIC_GLOVE_DETECTION('Property','Value',...) creates a new PLASTIC_GLOVE_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plastic_glove_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plastic_glove_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plastic_glove_detection

% Last Modified by GUIDE v2.5 23-Dec-2022 11:11:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plastic_glove_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @plastic_glove_detection_OutputFcn, ...
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


% --- Executes just before plastic_glove_detection is made visible.
function plastic_glove_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plastic_glove_detection (see VARARGIN)

% Choose default command line output for plastic_glove_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plastic_glove_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plastic_glove_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[File_Name, Path_Name] = uigetfile({'C:\Users\Sia De Long\Desktop\Dataset\*.jpg*'},'Select image');
fullname = fullfile(Path_Name,File_Name);
img = imread(fullname);
axis(handles.axes1);
imagesc(img);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
touchingdefect = 0;
thinnerdefect = 0;
doubledippingdefect = 0;

% Get the pop menu value
allItems = get(handles.popupmenu1,'string');
selectedIndex = get(handles.popupmenu1,'Value');
orientation = allItems{selectedIndex};

% Get the image 
img = getimage(handles.axes1);
%% Find Glove Area
% Convert image to gray scale
grayimg = rgb2gray(img);
% Thresholding glove area
glovearea = grayimg < 75;
% remove noise from reflection and only take one white area of the image
for c = 1:10
    glovearea = medfilt2(glovearea,[5,5]);
end
glovearea = imfill(glovearea,"holes");
glovearea = bwareafilt(glovearea,1);
%subplot(1,3,1), imshow(glovearea), title("Glove Area")
    

if(orientation == "Palm")
    %% Find Defect
    % Convert image to HSV
    hsvimg = rgb2hsv(img);
    defect = hsvimg(:,:,2) < 0.3;
    for c = 1:10
        defect = medfilt2(defect,[5,5]);
    end
    defect = bwareaopen(defect,100);
    %subplot(1,3,2), imshow(defect), title("Defect Area")
    
    %% Combine Glove Area and Defect Area
    % combine two area to remove hand area
    binarydefect = glovearea.*defect;
    binarydefect = imcomplement(binarydefect);
    %subplot(1,3,3), imshow(binarydefect), title("Hand and Defect Area")
    
    %% Create box for defect
    % find area for all the possible defects
    [label, numdefect] = bwlabel(binarydefect);
    props = regionprops(label, "BoundingBox", "Area");
    box = [props.BoundingBox];
    area = [props.Area];
    box = reshape(box,[4 numdefect]);
    defectBox = [];
    defectName = [];
    
    % Remove area that is too small or too big to be a defect
    % Identify the type of defect after removal
    for c = 1:length(area)
        if((area(c)>6500)&&(area(c)<20000))
            defectName = [defectName "Touching"];
            defectBox(:,end+1) = box(:,c);
            touchingdefect = touchingdefect+1;
        else 
            if((area(c)>30000)&&(area(c)<100000))
                defectName = [defectName "Thinner"];
                defectBox(:,end+1) = box(:,c);
                thinnerdefect = thinnerdefect+1;
            end    
        end
    end
    
    %% Combine Box and Original Image
    namec = 1;
    
    axis(handles.axes1);
    imagesc(img)
    for c = 1:size(defectBox,2)
        rectangle("Position", defectBox(:,c), "EdgeColor", "r");
        text(defectBox(1,c)-100, defectBox(2,c)-50, defectName(namec), "FontSize", 12, "Color", "r");
        namec = namec + 1;
    end

    %% Find the center and remove the right part of the glove area
    glovearea2 = glovearea;
    seg = regionprops(glovearea2,'Centroid');
    centroid = cat(1, seg.Centroid);
    %subplot(1,3,2), imshow(glovearea2), title('Centroid of The Glove');
    %hold(imgca,'on')
    %plot(imgca,centroid(1), centroid(2), 'r*') 
    %hold(imgca,'off')
    
    x = centroid(1);
    y = centroid(2);
    
    %% Remove the glove area with a circle
    [col,row] = size(glovearea2);

    glovesize = sum(glovearea2(:));
    if (glovesize > 3700000)
        r = 1100; 
    else
        if (glovesize > 3000000)
            r = 700;
        else
            r = 600;
        end
    end
    for i=1:col
        for j=1:row
            if ((i-y)^2)+((j-x)^2)<(r^2) 
                glovearea2(i,j) = 0;  
            end
        end
    end
    for c = 1:10
        glovearea2 = medfilt2(glovearea2,[5,5]);
    end
    %subplot(1,3,3), imshow(glovearea2), title('Circle of Glove Area Removed');
    
    %% Draw box on the glove
    [label, numFinger] = bwlabel(glovearea2);
    disp(numFinger);
    if(numFinger < 6)
        disp("Double Dipping Detected");
        [label, numglove] = bwlabel(glovearea);
        props = regionprops(label, "BoundingBox", "Area");
        box = [props.BoundingBox];
        box = reshape(box,[4 numglove]);


        rectangle("Position", box(:,1), "EdgeColor", "r");
        text(box(1,1)-100, box(1,1)-50, "Double Dipping", "FontSize", 12, "Color", "r");
        doubledippingdefect = doubledippingdefect+1;
    else
        disp("No Double Dipping Detected");
    end


else
    if(orientation == "Side")
        %% Find Defect
        % Convert image to HSV
        hsvimg = rgb2hsv(img);
        defect = hsvimg(:,:,2) < 0.3;
        for c = 1:10
            defect = medfilt2(defect,[5,5]);
        end
        defect = bwareaopen(defect,100);
        %subplot(1,3,2), imshow(defect), title("Defect Area")
        
        %% Combine Glove Area and Defect Area
        % combine two area to remove hand area
        binarydefect = glovearea.*defect;
        binarydefect = imcomplement(binarydefect);
        %subplot(1,3,3), imshow(binarydefect), title("Hand and Defect Area")
        
        %% Create box for defect
        % find area for all the possible defects
        [label, numdefect] = bwlabel(binarydefect);
        props = regionprops(label, "BoundingBox", "Area");
        box = [props.BoundingBox];
        area = [props.Area];
        box = reshape(box,[4 numdefect]);
        defectBox = [];
        defectName = [];
        
        % Remove area that is too small or too big to be a defect
        % Identify the type of defect after removal
        for c = 1:length(area)
            if((area(c)>6500)&&(area(c)<20000))
                defectName = [defectName "Touching"];
                defectBox(:,end+1) = box(:,c);
                touchingdefect = touchingdefect+1;
            end
        end
        
        %% Combine Box and Original Image
        namec = 1;
        
        axis(handles.axes1);
        imagesc(img)
        for c = 1:size(defectBox,2)
            rectangle("Position", defectBox(:,c), "EdgeColor", "r");
            text(defectBox(1,c)-100, defectBox(2,c)-50, defectName(namec), "FontSize", 12, "Color", "r");
            namec = namec + 1;
        end
    end
end

%str = sprintf('Hello world!\nThe value is %d', someVariable);
set(handles.text5, "String", "Black Plastic Glove");
set(handles.text6, "String", orientation);

strdefect =sprintf("Number of Touching Defect: " + touchingdefect + "\nNumber of Thinner Defect: " + thinnerdefect + "\nDouble Dipping Defect: " + doubledippingdefect);
set(handles.text7, "String", strdefect);

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
    close(plastic_glove_detection);
    
    % Create and display the second GUI
    GDD();
