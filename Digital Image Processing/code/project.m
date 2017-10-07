function varargout = project(varargin)
% PROJECT MATLAB code for project.fig
%      PROJECT, by itself, creates a new PROJECT or raises the existing
%      singleton*.
%
%      H = PROJECT returns the handle to a new PROJECT or the handle to
%      the existing singleton*.
%
%      PROJECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROJECT.M with the given input arguments.
%
%      PROJECT('Property','Value',...) creates a new PROJECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before project_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to project_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help project

% Last Modified by GUIDE v2.5 04-Jun-2017 01:31:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @project_OpeningFcn, ...
                   'gui_OutputFcn',  @project_OutputFcn, ...
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


% --- Executes just before project is made visible.
function project_OpeningFcn(hObject, eventdata, handles, varargin)
    global Selected;
    Selected = false;



% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to project (see VARARGIN)

% Choose default command line output for project
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes project wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = project_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Selected;
Selected = false;

[FileName,PathName] = uigetfile({'*.mp4';'*.avi'},'Select a video File');
videoPath = PathName;
if videoPath ==0
    disp('None selected');
    FileName = 'Nothing selected';
    set(handles.Heading, 'String', FileName);
else
    disp(videoPath);
    disp(FileName);
    Selected = true;
    set(handles.Heading, 'String', FileName);

    nm = strcat(videoPath,FileName);
    v = VideoReader(nm);
    global vidLoc;
    vidLoc = strcat(videoPath,FileName);

    axes(handles.axes4)
    imshow(read(v,1));
    
    
    
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Selected;

if Selected == false;
    set(handles.Heading, 'String', 'Please Select a video first!');
else
    set(handles.Heading, 'String', 'Processing.....');
    
    pause(1);
      %cartoonify here
    global vidLoc
    vidName = vidLoc;

    %read video and set the frame rateof output to the input
    a = VideoReader(vidName);
    get(a);
    fps = a.FrameRate;
    outputVideo = VideoWriter('Cartoonified.mp4');
    outputVideo.FrameRate = round(fps);
    open(outputVideo);

    %loop over all the frames
    
    for img = 1:a.NumberOfFrames;

        name = 'temp.jpg';
        im = read(a,img);
       %applying gauss filter to smooth img 
        im = imgaussfilt(im, 0.5);
        
       %For automated value of k first plot histogram of image. 3 one for 
       %RGB each then smooth the histogram using ka density function and 
       %finally find peaks using findpeaks function. Add peaks of all RGB. 
        %If k>12 set it to 12 because processing time gets too long
       
       
        i=rgb2gray(im);

        [f,xi] = ksdensity(imhist(i(:,:,1)));
        x=findpeaks([f,xi]);
        sx=size(x);
        Rpeaks=sx(1,2);


        [f,xi] = ksdensity(imhist(i(:,1,:)));
        y=findpeaks([f,xi]);
        sy=size(y);
        Gpeaks=sy(1,2);

        [f,xi] = ksdensity( imhist(i(1,:,:)));
        z=findpeaks([f,xi]);
        sz=size(z);
        Bpeaks=sz(1,2);

        TotalPeaks=1+( Rpeaks+Gpeaks+Bpeaks);
        if(TotalPeaks>12)
            TotalPeaks=12;
        end

        K = TotalPeaks; % this is the number of k 

          % In matlab, K-means operates on a 2D array, where each sample is one row,
        % and the features are the columns. We can use the reshape function to turn
        % the image into this format, where each pixel is one row, and R,G and B
        % are the columns. We are turning a W,H,3 image into W*H,3

        % We also cast to a double array, because K-means requires it in matlab
        imflat = double(reshape(im, size(im,1) * size(im,2), 3));

        % I specify that initialisation shuold sample points at
        % random, rather than anything complex like kmeans++ initialisation.
        % Kmeans++ takes a long time if you are using 256 classes.

        % Perform k-means. This function returns the class IDs assigned to each
        % pixel, and in this case we also want the mean values for each class -
        % what colour is each class. This can take a long time if the value for K
        % is large, I've used the sampling start strategy to speed things up.

        % While KMeans is running, it will show you the iteration count, and the
        % number of pixels that have changed class since last iteration. This
        % number should get lower and lower, as the means settle on appropriate
        % values. For large K, it's unlikely that we will ever reach zero movement
        % (convergence) within 150 iterations.

        [kIDs, kC] = kmeans(imflat, K, 'Display', 'final', 'MaxIter', 1000, 'Start', 'uniform');

        % Matlab can output paletted images, that is, grayscale images where the
        % colours are stored in a separate array. This array is kC, and kIDs are
        % the grayscale indices.
        colormap = kC / 256; % Scale 0-1, since this is what matlab wants

        % Reshape kIDs back into the original image shape
        imout = reshape(uint8(kIDs), size(im,1), size(im,2));

        % Save file out, you need to subtract 1 from the image classes, since once
        % stored in the file the values should go from 0-255, not 1-256 like matlab
        % would do.

        imwrite(imout - 1, colormap, name);
        Frame = imread(name);
        
        %add processed frame to output video
        writeVideo(outputVideo,Frame)

    end
    close(outputVideo);
    set(handles.Heading, 'String', 'DONE!');
    fprintf('Done!');
    
    
end 
   
