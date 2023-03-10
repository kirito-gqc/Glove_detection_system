function varargout = GDD(varargin)
% GDD MATLAB code for GDD.fig
%      GDD, by itself, creates a new GDD or raises the existing
%      singleton*.
%
%      H = GDD returns the handle to a new GDD or the handle to
%      the existing singleton*.
%
%      GDD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GDD.M with the given input arguments.
%
%      GDD('Property','Value',...) creates a new GDD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GDD_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GDD_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GDD

% Last Modified by GUIDE v2.5 20-Dec-2022 11:45:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GDD_OpeningFcn, ...
                   'gui_OutputFcn',  @GDD_OutputFcn, ...
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


% --- Executes just before GDD is made visible.
function GDD_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GDD (see VARARGIN)

% Choose default command line output for GDD
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GDD wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GDD_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % Close the first GUI
    close(GDD);
    
    % Create and display the second GUI
    latex_glove_detection();


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % Close the first GUI
    close(GDD);
    
    % Create and display the second GUI
    cloth_glove_detection();


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % Close the first GUI
    close(GDD);
    
    % Create and display the second GUI
    plastic_glove_detection();
