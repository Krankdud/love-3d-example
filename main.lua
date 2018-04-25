local cpml = require "lib.cpml"

local pixelShader = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texcolor = Texel(texture, texture_coords);
        return texcolor * color;
    }
]]

local vertexShader = [[
    uniform mat4 model;
    uniform mat4 projection;
    uniform mat4 view;

    vec4 position(mat4 _, vec4 vertex_position)
    {
        return projection * view * model * vertex_position;
    }
]]

function love.load()
    -- Vertex format. Adds z coordinate to VertexPosition.
    local format = {
        {"VertexPosition", "float", 3},
        {"VertexTexCoord", "float", 2},
        {"VertexColor", "byte", 4}
    }

    -- List of vertices that creates a cube out of triangles.
    local vertices = {
        {-0.5, -0.5, -0.5,  0.0, 0.0},
        {0.5,  0.5, -0.5,  1.0, 1.0},
        {0.5, -0.5, -0.5,  1.0, 0.0},
        {0.5,  0.5, -0.5,  1.0, 1.0},
        {-0.5, -0.5, -0.5,  0.0, 0.0},
        {-0.5,  0.5, -0.5,  0.0, 1.0},

        {-0.5, -0.5,  0.5,  0.0, 0.0},
        {0.5, -0.5,  0.5,  1.0, 0.0},
        {0.5,  0.5,  0.5,  1.0, 1.0},
        {0.5,  0.5,  0.5,  1.0, 1.0},
        {-0.5,  0.5,  0.5,  0.0, 1.0},
        {-0.5, -0.5,  0.5,  0.0, 0.0},

        {-0.5,  0.5,  0.5,  1.0, 0.0},
        {-0.5,  0.5, -0.5,  1.0, 1.0},
        {-0.5, -0.5, -0.5,  0.0, 1.0},
        {-0.5, -0.5, -0.5,  0.0, 1.0},
        {-0.5, -0.5,  0.5,  0.0, 0.0},
        {-0.5,  0.5,  0.5,  1.0, 0.0},

        {0.5,  0.5,  0.5,  1.0, 0.0},
        {0.5, -0.5, -0.5,  0.0, 1.0},
        {0.5,  0.5, -0.5,  1.0, 1.0},
        {0.5, -0.5, -0.5,  0.0, 1.0},
        {0.5,  0.5,  0.5,  1.0, 0.0},
        {0.5, -0.5,  0.5,  0.0, 0.0},

        {-0.5, -0.5, -0.5,  0.0, 1.0},
        {0.5, -0.5, -0.5,  1.0, 1.0},
        {0.5, -0.5,  0.5,  1.0, 0.0},
        {0.5, -0.5,  0.5,  1.0, 0.0},
        {-0.5, -0.5,  0.5,  0.0, 0.0},
        {-0.5, -0.5, -0.5,  0.0, 1.0},

        {-0.5,  0.5, -0.5,  0.0, 1.0},
        {0.5,  0.5,  0.5,  1.0, 0.0},
        {0.5,  0.5, -0.5,  1.0, 1.0},
        {0.5,  0.5,  0.5,  1.0, 0.0},
        {-0.5,  0.5, -0.5,  0.0, 1.0},
        {-0.5,  0.5,  0.5,  0.0, 0.0}
    }

    shader = love.graphics.newShader(pixelShader, vertexShader)

    -- Create the mesh
    local texture = love.graphics.newImage("assets/crate.png")
    mesh = love.graphics.newMesh(format, vertices, "triangles")
    mesh:setTexture(texture)

    -- Model is a matrix used to rotate the cube
    model = cpml.mat4.identity()

    -- Set the position of the camera
    local cameraPos = cpml.vec3.new(0, 0, -3)
    view = cpml.mat4.identity()
    view = view:translate(view, cameraPos)

    -- Create a perspective projection
    projection = cpml.mat4.from_perspective(45, love.graphics.getWidth() / love.graphics.getHeight(), 0.1, 1000)

    -- Create a canvas to draw on. This is needed for drawing with depth
    canvas = love.graphics.newCanvas()
end

function love.update(dt)
    model = model:rotate(model, math.rad(40) * dt, cpml.vec3.new(1, 1, 0))
end

function love.draw()
    -- Set the canvas, and enable depth testing.
    -- You can also set depthstencil to be a canvas with one of the depth formats
    -- instead of setting depth to true. (See: https://love2d.org/wiki/PixelFormat)
    love.graphics.setCanvas({canvas, depth=true})
    love.graphics.setShader(shader)
    -- Set depth mode to lequal, and make sure we are writing to the depth buffer
    love.graphics.setDepthMode("lequal", true)

    love.graphics.clear()

    -- cpml's matrices are column-major, love sends matrices as row-major as default
    -- so ensure the matrix layout is set to column
    shader:send("model", "column", model)
    shader:send("view", "column", view)
    shader:send("projection", "column", projection)
    love.graphics.draw(mesh)

    love.graphics.setShader()
    love.graphics.setCanvas()

    love.graphics.draw(canvas)

    love.graphics.print(string.format("%d fps", love.timer.getFPS()))
end
