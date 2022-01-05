local Deque = {}

function Deque.new()
    return setmetatable({front = 0, back = -1}, {__index = Deque})
end

function Deque.Count(queue)
    if queue then
        return queue.back - queue.front + 1
    end
    return 0
end

function Deque.PushBack(queue, val)
    if queue then
        queue.back = queue.back + 1
        queue[queue.back] = val
    end
end

function Deque.PopBack(queue)
    local popVal = nil
    if queue then
        if Deque.Count(queue) > 0 then
            popVal = queue[queue.back]
            queue[queue.back] = nil
            queue.back = queue.back - 1
        end
    end
    return popVal
end

function Deque.PushFront(queue, val)
    if queue then
        queue.front = queue.front - 1
        queue[queue.front] = val
    end
end

function Deque.PopFront(queue)
    local popVal = nil
    if queue then
        if Deque.Count(queue) > 0 then
            popVal = queue[queue.front]
            queue[queue.front] = nil
            queue.front = queue.front + 1
        end
    end
    return popVal
end

function Deque.Front(queue)
    if queue then
        return queue[queue.front]
    end
    return nil
end

function Deque.Back(queue)
    if queue then
        return queue[queue.back]
    end
    return nil
end

function Deque.Clear(queue)
    if queue then
        queue = Deque.new()
    end
end

return Deque