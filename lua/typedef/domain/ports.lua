---@class CodegenRepository
---@field generate fun(self: CodegenRepository, input: string, input_type: string, format: string): Promise

---@class InputReader
---@field read fun(self: InputReader): string

---@class OutputWriter
---@field write fun(self: OutputWriter, output: string)
