export const success = (res, data, msg="Success") => {
  res.status(200).json({ status: "success", message: msg, data });
};

export const error = (res, err, code=500) => {
  res.status(code).json({ status: "error", message: err.message || err });
};
