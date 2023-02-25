function varargout = latex_glove_detection(varargin)
% LATEX_GLOVE_DETECTION MATLAB code for latex_glove_detection.fig
%      LATEX_GLOVE_DETECTION, by itself, creates a new LATEX_GLOVE_DETECTION or raises the existing
%      singleton*.
%
%      H = LATEX_GLOVE_DETECTION returns the handle to a new LATEX_GLOVE_DETECTION or the handle to
%      the existing singleton*.
%
%      LATEX_GLOVE_DETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LATEX_GLOVE_DETECTION.M with the given input arguments.
%
%      LATEX_GLOVE_DETECTION('Property','Value',...) creates a new LATEX_GLOVE_DETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before latex_glove_detection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to latex_glove_detection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help latex_glove_detection

% Last Modified by GUIDE v2.5 20-Dec-2022 15:21:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @latex_glove_detection_OpeningFcn, ...
                   'gui_OutputFcn',  @latex_glove_detection_OutputFcn, ...
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


% --- Executes just before latex_glove_detection is made visible.
function latex_glove_detection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to latex_glove_detection (see VARARGIN)

% Choose default command line output for latex_glove_detection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes latex_glove_detection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = latex_glove_detection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
[File_Name, Path_Name] = uigetfile({'D:\Degree 3 - Image Processing\dataset\*.jpeg*'},'Select image');
fullname = fullfile(Path_Name,File_Name);
im = imread(fullname);
axis(handles.axes1);
imshow(im);




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    orientation = getappdata(handles.figure1, 'orientation');
    input = get(handles.axes1,'Children');
    finger_defect=[];
    finger_defect_box = [];
    dirty_hole_defect=[]; 
    dirty_hole_defect_box=[];
    % Get the image data from the object
    input_image = get(input, 'CData');
    if isempty(input)
        % Display an error message if the axes is empty
        errordlg('Error: You did not load image!','Error Message','modal');
    elseif (string(orientation)=="Select Orientation")
        % Display an error message if the select orientation is empty
        errordlg('Error: You did not select orientation!','Error Message','modal');        
    else
        percentblue = gloveidentifier(input_image);
        if (percentblue>= 5)
            glovetype = "Latex glove";
       
            if (string(orientation)=="Palm")
                fingernum = finger_counter(input_image);
                if (fingernum ~= 5)
                    [finger_defect, finger_defect_box] = finger_not_enough_detection(input_image,string(orientation));
                end
            else
                [finger_defect, finger_defect_box] = finger_not_enough_detection(input_image,string(orientation));
            end
            [dirty_hole_defect, dirty_hole_defect_box] = dirty_and_hole_detection(input_image,string(orientation));
         else
            glovetype = "Not latex glove";
            errordlg('The image given is not a blue latex glove', 'Error Message','modal');
        end
    end
    finger_defect_num = length(finger_defect);
    dirty_defect_num = sum(strcmp(dirty_hole_defect, 'Dirty and Stain'));
    hole_defect_num = sum(strcmp(dirty_hole_defect,'Hole'));
    finger_defect_num = num2str(finger_defect_num);
    dirty_defect_num = num2str(dirty_defect_num);
    hole_defect_num = num2str(hole_defect_num);
    finger_defect_list = strcat("Finger not enough defect: ", finger_defect_num);
    dirty_defect_list = strcat("Dirty and stain defect: ", dirty_defect_num);
    hole_defect_list = strcat("Hole defect: ", hole_defect_num);
    defect_list = sprintf('%s\n%s\n%s',finger_defect_list,dirty_defect_list,hole_defect_list);
    defect_name = cat(2, finger_defect, dirty_hole_defect);
    defect_box = horzcat(finger_defect_box,dirty_hole_defect_box);
    set(handles.text5,'String',glovetype);
    set(handles.text6, 'String', orientation);
    set(handles.text7,'String', defect_list);
    axis(handles.axes1);
    imshow(input_image);
    %Draw bounding box
    %Set the font size and color for the label
    fontSize = 8;
    fontColor = 'red';
    hold on;
    for cnt = 1:size(defect_box,2)
        rectangle('position', defect_box(:,cnt),'EdgeColor','r');
        text(defect_box(1,cnt), defect_box(2,cnt)-25, defect_name(cnt), ...
        'FontSize', fontSize, 'Color', fontColor);
    end
    hold off;
    
%     % Delete each child handle
%     for i = 1:numel(input)
%         delete(input(i));
%     end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
    % Get the value of the pop-out menu
    value = get(hObject, 'Value');
    
    % Get the list of strings in the pop-out menu
    strings = get(hObject, 'String');
    
    % Get the selected string
    selected_string = strings{value};
    
    % Do something with the selected string
    setappdata(handles.figure1, 'orientation', selected_string);



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
    close(latex_glove_detection);
    
    % Create and display the second GUI
    GDD();

% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
