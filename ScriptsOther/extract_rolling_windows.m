% [INPUT]
% data = A float t-by-n matrix containing the time series.
% bandwidth = An integer [21,252] representing the dimension of each rolling window.
% truncate = A boolean that indicates whether to exclude all the rolling windows with a dimension less than the bandwidth (optional, default=true).
%
% [OUTPUT]
% windows = A vector of float bandwidth-by-n matrices representing the rolling windows.
%
% [NOTES]
% If the number of observations is less than or equal to the specified bandwidth, a single rolling window containing all the observations is returned.

function windows = extract_rolling_windows(varargin)

    persistent ip;

    if (isempty(ip))
        ip = inputParser();
        ip.addRequired('data',@(x)validateattributes(x,{'double'},{'2d','nonempty'}));
        ip.addRequired('bandwidth',@(x)validateattributes(x,{'double'},{'real','finite','integer','>=',21,'<=',252,'scalar'}));
        ip.addRequired('truncate',@(x)validateattributes(x,{'logical'},{'scalar'}));
    end

    ip.parse(varargin{:});
    ipr = ip.Results;
    
    nargoutchk(1,1);
    
    windows = extract_rolling_windows_internal(ipr.data,ipr.bandwidth,ipr.truncate);

end

function windows = extract_rolling_windows_internal(data,bandwidth,truncate)

    t = size(data,1);
    
    if (bandwidth >= t)
        windows = cell(1,1);
        windows{1} = data;
        return;
    end
    
    limit = t - bandwidth + 1;

    if (truncate)
        windows = cell(limit,1);

        for i = 1:limit
            windows{i} = data(i:bandwidth+i-1,:);
        end
    else
        windows = cell(t,1);
        
        k = round(nthroot(bandwidth,1.81),0);

        for i = 1:(bandwidth - 1)
            windows{i} = data(1:max(i,k),:);
        end
        
        for i = 1:limit
            windows{i+bandwidth-1} = data(i:bandwidth+i-1,:);
        end
    end

end