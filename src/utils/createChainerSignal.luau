local signal = require(script.Parent.Parent.packages.signal)

type signalChainer<T...> = (T...) -> ()

function createChainerSignal<T...>(signal: signal.Signal<T...>): (signal.Signal<T...>, signalChainer<T...>)
    return signal, function(...)
        signal:Fire(...)
    end
end

return createChainerSignal
